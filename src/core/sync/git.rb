class Fizzy::Sync::Git < Fizzy::Sync::Base
  include Fizzy::IO
  include Fizzy::Execution
  include Fizzy::Filesystem

  def initialize(local_dir_path, remote_url)
    super(:git, local_dir_path, remote_url)
    @remote_normalized_url = normalize_url(@remote_url)
  end

  #
  # Check if the synchronizer is enabled.
  #
  def enabled?
    (super ||
     (!@remote_url.nil? && @remote_url.to_s.start_with?("#{@name}:")) ||
     local_valid_repo?)
  end

  #
  # Update local from remote.
  #
  def update_local
    if local_valid_repo?
      # Update existing local from remote, i.e. perform `git pull`.
      info "Syncing from #{✏ "origin"} to #{✏ "local"}."
      status   = perform_commit
      status &&= perform_pull
    else
      # Update non-existing local from remote, i.e. perform `git clone`.
      perform_clone
    end
  end

  # Update remote from local.
  #
  def update_remote
    info "Syncing from #{✏ "local"} to #{✏ "origin"}."
    status   = perform_commit
    status &&= perform_push
  end

  # Check if local is changed, and now is different from latest remote state.
  #
  def local_changed?
    info "Checking if local repository is changed."
    return false unless local_valid_repo?
    return true if working_tree_changes?
    return true if perform_fetch && should_push?
    false
  end

  # Check if remote is changed, and now is different from latest local state.
  #
  def remote_changed?
    info "Checking if remote repository is changed."
    return true unless local_valid_repo?
    return true if perform_fetch && should_pull?
    false
  end

  #
  # Normalize the remote git URL.
  #
  protected def normalize_url(url, default_protocol: :ssh)
    return nil if url.nil?
    url       = url.to_s.gsub(/^#{@name}:/, "") # Remove VCS name prefix (optional).
    protocols = %i[https ssh]

    regexp = %r{
      ^
      (?<protocol>#{protocols.map { |p| "#{p}:" }.join("|")})?
      (?<username>[a-z0-9\-_]+)
      \/
      (?<repository>[a-z0-9\-_]+)
      $
    }xi

    md = url.match(regexp)
    return url unless md
    protocol = (md[:protocol] || default_protocol).to_s.gsub(/:$/, "").to_sym
    case protocol
    when :ssh   then "git@github.com:#{md[:username]}/#{md[:repository]}"
    when :https then "https://github.com/#{md[:username]}/#{md[:repository]}"
    else             error "Invalid protocol for #{✏ url}: #{✏ protocol} not in #{✏ protocols}."
    end
  end

  #
  # Check if the local directory holds a valid git repository.
  #
  protected def local_valid_repo?
    @local_dir_path.directory? && @local_dir_path.join(".git").directory?
  end

  #
  # Get the working tree (local) changes.
  #
  protected def working_tree_changes
    error "Invalid local repo #{✏ @local_dir_path}." unless local_valid_repo?
    FileUtils.cd(@local_dir_path) do
      return `git status -uall --porcelain`.strip
    end
  end

  #
  # Check if there are some changes in the Working Tree.
  #
  protected def working_tree_changes?
    !working_tree_changes.empty?
  end

  #
  # Get a {Hash} containing information about the local and remote repository.
  #
  protected def info
    error "Invalid local repo #{✏ @local_dir_path}." unless local_valid_repo?
    FileUtils.cd(@local_dir_path) do
      local  = `git rev-parse @ 2> /dev/null`.strip
      local  = nil unless $CHILD_STATUS.success?
      remote = `git rev-parse @{u} 2> /dev/null`.strip
      remote = nil unless $CHILD_STATUS.success?
      base   = `git merge-base @ @{u} 2> /dev/null`.strip
      base   = nil unless $CHILD_STATUS.success?
      return { local: local, remote: remote, base: base }
    end
  end

  #
  # Check if a {Fizzy::Sync::Git#perform_pull} operation is needed.
  #
  protected def should_pull?
    info[:remote] != info[:base]
  end

  #
  # Check if a {Fizzy::Sync::Git#perform_push} operation is needed.
  #
  protected def should_push?
    info[:local] != info[:base]
  end

  #
  # Get the list of the available remote git repositories.
  #
  protected def remotes
    error "Invalid local repo #{✏ @local_dir_path}" unless local_valid_repo?
    FileUtils.cd(@local_dir_path) do
      return `git remote`.split(/\W+/).reject(&:empty?)
    end
  end

  #
  # Get the list of the available git branches.
  #
  protected def branches
    error "Invalid local repo #{✏ @local_dir_path}." unless local_valid_repo?
    FileUtils.cd(@local_dir_path) do
      return `git branch`.split(/\W+/).reject(&:empty?)
    end
  end

  # Add the changes from the Working Tree to the stage.
  #
  protected def perform_add(files: nil, interactive: false)
    error "Invalid files #{✏ files}." unless files.nil? || files.is_a?(Array)

    cmd = %w[git add]
    cmd << "-i" if interactive
    cmd << "-A" if files.nil?
    cmd << files unless files.nil?

    error "Invalid local repo #{✏ @local_dir_path}." unless local_valid_repo?
    exec_cmd(cmd, as_su: !existing_dir(@local_dir_path), chdir: @local_dir_path)
  end

  #
  # Commit the changes in the Working Tree.
  #
  protected def perform_commit(message: nil)
    status = true

    if working_tree_changes?
      info "The configuration has the following local changes:\n#{✏ working_tree_changes}."
      if message || ask("Do you want to commit them all")
        status &&= perform_add # Add from Working Tree to stage.
        if status
          info "Performing commit."

          message ||= ask("Type the commit message", type: :string)

          cmd = ["git", "commit", "-a"]
          cmd << "--allow-empty-message" if message.nil?
          cmd += ["-m", message] unless message.nil?

          error "Invalid local repo: #{✏ @local_dir_path}" unless local_valid_repo?
          status &&= exec_cmd(cmd,
                              as_su: !existing_dir(@local_dir_path),
                              chdir: @local_dir_path)
        end
      end
    end

    status
  end

  protected def perform_fetch(remote: nil, branch: nil)
    error "Invalid remote #{✏ remote}." if remote && !remotes.include?(remote)
    error "Invalid branch #{✏ branch}." if branch && !branches.include?(branch)

    info "Fetching information from remote."

    cmd = %w[git fetch]
    cmd << remote.shell_escape unless remote.nil?
    cmd << branch.shell_escape unless branch.nil?

    error "Invalid local repo #{✏ @local_dir_path}." unless local_valid_repo?
    exec_cmd(cmd, as_su: !existing_dir(@local_dir_path), chdir: @local_dir_path)
  end

  protected def perform_clone(recursive: true)
    info "Syncing from remote repository #{✏ @remote_normalized_url}."
    error "Invalid url: can't be empty." if @remote_normalized_url.nil?

    parent_dir = @local_dir_path.dirname
    name       = @local_dir_path.basename

    cmd = %w[git clone]
    cmd << "--recursive" if recursive
    cmd << @remote_normalized_url.shell_escape
    cmd << name.shell_escape

    exec_cmd(cmd, as_su: !existing_dir(parent_dir), chdir: parent_dir)
  end

  #
  # Pull from the provided `remote` in the provided `branch`.
  #
  protected def perform_pull(remote: nil, branch: nil, with_submodules: true)
    error "Invalid remote #{✏ remote}." if remote && !remotes.include?(remote)
    error "Invalid branch #{✏ branch}." if branch && !branches.include?(branch)

    status = true

    if should_pull?
      info "Peforming pull."

      cmd = %w[git pull]
      cmd << remote.shell_escape unless remote.nil?
      cmd << branch.shell_escape unless branch.nil?

      error "Invalid local repo #{✏ @local_dir_path}." unless local_valid_repo?
      status = exec_cmd(cmd,
                        as_su: !existing_dir(@local_dir_path),
                        chdir: @local_dir_path)

      if with_submodules
        status &&= exec_cmd(%w[git submodule update --recursive],
                            as_su: !existing_dir(@local_dir_path),
                            chdir: @local_dir_path)
      end
    end

    status
  end

  #
  # Push to the provided `remote` in the provided `branch`.
  #
  protected def perform_push(remote: nil, branch: nil)
    error "Invalid remote #{✏ remote}." if remote && !remotes.include?(remote)
    error "Invalid branch #{✏ branch}." if branch && !branches.include?(branch)

    status = true

    if should_push?
      info "Pushing to remote."

      cmd = %w[git push]
      cmd << remote.shell_escape unless remote.nil?
      cmd << branch.shell_escape unless branch.nil?

      error "Invalid local repo: #{✏ @local_dir_path}." unless local_valid_repo?
      status &&= exec_cmd(cmd,
                          as_su: !existing_dir(@local_dir_path),
                          chdir: @local_dir_path)
    end

    status
  end
end
