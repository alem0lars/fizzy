class Fizzy::Sync::Git < Fizzy::Sync::Base

  include Fizzy::IO
  include Fizzy::Execution
  include Fizzy::Filesystem

  def initialize(local_dir_path, remote_url)
    super(:git, local_dir_path, remote_url)
    @remote_normalized_url = normalize_url(@remote_url)
  end

  # Check if the synchronizer is enabled.
  #
  def enabled?
    local_valid_repo? ||
      !@remote_url.nil? && @remote_url.start_with?("#{@name}:") ||
      super
  end

  # Update local from remote.
  #
  def update_local
    if local_valid_repo?
      # Update existing local from remote, i.e. perform `git pull`.
      tell("Syncing from `origin` to local", :blue)
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
    tell("Syncing from local to `origin`", :blue)
    status   = perform_commit
    status &&= perform_push
  end

  # Check if local is changed, and now is different from latest remote state.
  #
  def local_changed?
    tell("Checking if local repository is changed", :blue)
    return false unless local_valid_repo?
    return true if working_tree_changes?
    return true if perform_fetch && should_push?
    false
  end

  # Check if remote is changed, and now is different from latest local state.
  #
  def remote_changed?
    tell("Checking if remote repository is changed", :blue)
    return true unless local_valid_repo?
    return true if perform_fetch && should_pull?
    false
  end

protected

  # Normalize the remote git URL.
  #
  def normalize_url(url, default_protocol: :ssh)
    return nil if url.nil?
    protocols = %i(https ssh)
    url = url.gsub(/^#{@name}:/, "") # Remove VCS name prefix (optional).
    regexp = %r{
      ^
      (?<protocol>#{protocols.map{|p| "#{p}:"}.join("|")})?
      (?<username>[a-z0-9\-_]+)
      \/
      (?<repository>[a-z0-9\-_]+)
      $
    }xi
    md = url.match(regexp)
    return url unless md
    protocol = (md[:protocol].gsub(/:$/, "") || default_protocol).to_sym
    case protocol
      when :ssh   then "git@github.com:#{md[:username]}/#{md[:repository]}"
      when :https then "https://github.com/#{md[:username]}/#{md[:repository]}"
      else        error("Invalid protocol for `#{url}`: `#{protocol}` not in " +
                        "`[#{protocols.join(", ")}]`.")
    end
  end

  # Check if the local directory holds a valid git repository.
  #
  def local_valid_repo?
    @local_dir_path.directory? && @local_dir_path.join(".git").directory?
  end

  # Get the Working Tree (local) changes.
  #
  def working_tree_changes
    error("Invalid local repo: `#{@local_dir_path}`") unless local_valid_repo?
    FileUtils.cd(@local_dir_path) do
      return `git status -uall --porcelain`.strip
    end
  end

  # Check if there are some changes in the Working Tree.
  #
  def working_tree_changes?
    !working_tree_changes.empty?
  end

  # Get a `Hash` containing information about the local and remote repository.
  #
  def info
    error("Invalid local repo: `#{@local_dir_path}`") unless local_valid_repo?
    FileUtils.cd(@local_dir_path) do
      return {
        local:  `git rev-parse @`.strip,
        remote: `git rev-parse @{u}`.strip,
        base:   `git merge-base @ @{u}`.strip
      }
    end
  end

  # Check if a `pull` operation is needed.
  #
  def should_pull?
    info[:remote] != info[:base]
  end

  # Check if a `push` operation is needed.
  #
  def should_push?
    info[:local] != info[:base]
  end

  # Get the list of the available remote git repositories.
  #
  def remotes
    error("Invalid local repo: `#{@local_dir_path}`") unless local_valid_repo?
    FileUtils.cd(@local_dir_path) do
      return `git remote`.split(/\W+/).reject(&:empty?)
    end
  end

  # Get the list of the available git branches.
  #
  def branches
    error("Invalid local repo: `#{@local_dir_path}`") unless local_valid_repo?
    FileUtils.cd(@local_dir_path) do
      return `git branch`.split(/\W+/).reject(&:empty?)
    end
  end

  # Add the changes from the Working Tree to the stage.
  #
  def perform_add(files: nil, interactive: false)
    error("Invalid files `#{files}`.") unless files.nil? || files.is_a?(Array)

    cmd  = ["git", "add"]
    cmd << "-i"  if interactive
    cmd << "-A"  if files.nil?
    cmd << files unless files.nil?

    error("Invalid local repo: `#{@local_dir_path}`") unless local_valid_repo?
    exec_cmd(cmd, as_su: !existing_dir(@local_dir_path), chdir: @local_dir_path)
  end

  # Commit the changes in the Working Tree.
  #
  def perform_commit
    status = true

    if working_tree_changes?
      tell "The configuration has the following local changes:\n" +
           "#{colorize(working_tree_changes, :white)}", :cyan
      if quiz("Do you want to commit them all")
        status &&= perform_add # Add from Working Tree to stage.
        if status
          tell("Performing commit", :blue)

          message = quiz("Type the commit message", type: :string)

          cmd  = ["git", "commit", "-a"]
          cmd << "--allow-empty-message" if     message.nil?
          cmd += ["-m", message]         unless message.nil?

          error("Invalid local repo: `#{@local_dir_path}`") unless local_valid_repo?
          status &&= exec_cmd(cmd,
                              as_su: !existing_dir(@local_dir_path),
                              chdir: @local_dir_path)
        end
      end
    end

    status
  end

  def perform_fetch(remote: nil, branch: nil)
    error("Invalid remote `#{remote}`.") if remote && !remotes.include?(remote)
    error("Invalid branch `#{branch}`.") if branch && !branches.include?(branch)

    tell("Fetching information from remote", :blue)

    cmd  = ["git", "fetch"]
    cmd << remote.shell_escape unless remote.nil?
    cmd << branch.shell_escape unless branch.nil?

    error("Invalid local repo: `#{@local_dir_path}`") unless local_valid_repo?
    exec_cmd(cmd, as_su: !existing_dir(@local_dir_path), chdir: @local_dir_path)
  end

  def perform_clone(recursive: true)
    tell("Syncing from remote repository: `#{@remote_normalized_url}`", :blue)
    error("Invalid url: can't be empty.") if @remote_normalized_url.nil?

    parent_dir = @local_dir_path.dirname
    name = @local_dir_path.basename

    cmd  = ["git", "clone"]
    cmd << "--recursive" if recursive
    cmd << @remote_normalized_url.shell_escape
    cmd << name.shell_escape

    exec_cmd(cmd, as_su: !existing_dir(parent_dir), chdir: parent_dir)
  end

  # Pull from the provided `remote` in the provided `branch`.
  #
  def perform_pull(remote: nil, branch: nil, with_submodules: true)
    error("Invalid remote `#{remote}`") if remote && !remotes.include?(remote)
    error("Invalid branch `#{branch}`") if branch && !branches.include?(branch)

    status = true

    if should_pull?
      tell("Performing pull", :blue)

      cmd  = ["git", "pull"]
      cmd << remote.shell_escape unless remote.nil?
      cmd << branch.shell_escape unless branch.nil?

      error("Invalid local repo: `#{@local_dir_path}`") unless local_valid_repo?
      status = exec_cmd(cmd,
                        as_su: !existing_dir(@local_dir_path),
                        chdir: @local_dir_path)

      if with_submodules
        status &&= exec_cmd(%w(git submodule update --recursive),
                            as_su: !existing_dir(@local_dir_path),
                            chdir: @local_dir_path)
      end
    end

    status
  end

  # Push to the provided `remote` in the provided `branch`.
  #
  def perform_push(remote: nil, branch: nil)
    error("Invalid remote `#{remote}`") if remote && !remotes.include?(remote)
    error("Invalid branch `#{branch}`") if branch && !branches.include?(branch)

    status = true

    if should_push?
      tell("Pushing to remote", :blue)

      cmd  = ["git", "push"]
      cmd << remote.shell_escape unless remote.nil?
      cmd << branch.shell_escape unless branch.nil?

      error("Invalid local repo: `#{@local_dir_path}`") unless local_valid_repo?
      status &&= exec_cmd(cmd,
                          as_su: !existing_dir(@local_dir_path),
                          chdir: @local_dir_path)
    end

    status
  end

end
