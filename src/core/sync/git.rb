class Fizzy::Sync::Git < Fizzy::Sync::Base

  include Fizzy::IO
  include Fizzy::Execution
  include Fizzy::Filesystem

  def initialize(local_dir_path, remote_url)
    super
    @vcs_name = :git
    @remote_normalized_url = normalize_url(@remote_url)
  end

  # Check if the synchronizer is enabled.
  #
  def enabled?
    local_valid_repo? || @remote_url.start_with?("#{@vcs_name}:") || super
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
    perform_fetch && should_push?
  end

  # Check if remote is changed, and now is different from latest local state.
  #
  def remote_changed?
    perform_fetch && should_pull?
  end

  # Normalize the remote git URL.
  #
  protected def normalize_url(url, default_protocol: :ssh)
    protocols = %i(https ssh)
    url = url.gsub(/^#{@vcs_name}:/, "") # Remove VCS name prefix (optional).
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
    case (md[:protocol] || default_protocol.to_s).to_sym
      when :ssh   then "git@github.com:#{md[:username]}/#{md[:repository]}"
      when :https then "https://github.com/#{md[:username]}/#{md[:repository]}"
      else        error("Invalid protocol for `#{url}`: not in " +
                        "`[#{protocols.join(", ")}]`.")
    end
  end

  # Check if the local directory holds a valid git repository.
  #
  protected def local_valid_repo?
    @local_dir_path.directory? && @local_dir_path.join(".git").directory?
  end

  # Get the Working Tree (local) changes.
  #
  protected def working_tree_changes
    FileUtils.cd(@local_dir_path) do
      return `git status -uall --porcelain`.strip
    end
  end

  # Check if there are some changes in the Working Tree.
  #
  protected def working_tree_changes?
    !working_tree_changes.empty?
  end

  # Get a `Hash` containing information about the local and remote repository.
  #
  protected def info
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
  protected def should_pull?
    info[:remote] != info[:base]
  end

  # Check if a `push` operation is needed.
  #
  protected def should_push?(git_root_path)
    info[:local] != info[:base]
  end

  # Get the list of the available remote git repositories.
  #
  protected def remotes
    FileUtils.cd(@local_dir_path) do
      return `git remote`.split(/\W+/).reject(&:empty?)
    end
  end

  # Get the list of the available git branches.
  #
  protected def branches
    FileUtils.cd(@local_dir_path) do
      return `git branch`.split(/\W+/).reject(&:empty?)
    end
  end

  # Add the changes from the Working Tree to the stage.
  #
  protected def perform_add(files: nil, interactive: false)
    error("Invalid files `#{files}`.") unless files.nil? || files.is_a?(Array)

    cmd  = ["git add"]
    cmd << "-i"  if interactive
    cmd << "-A"  if files.nil?
    cmd << files unless files.nil?

    exec_cmd(cmd, as_su: !existing_dir(@local_dir_path), chdir: @local_dir_path)
  end

  # Commit the changes in the Working Tree.
  #
  protected def perform_commit
    status = false
    if working_tree_changes?
      tell "The configuration has the following local changes:\n" +
           "#{colorize(working_tree_changes, :white)}", :cyan
      if quiz("Do you want to commit them all")
        status = perform_add # Add from Working Tree to stage.
        if status
          tell("Performing commit", :blue)

          message = quiz("Type the commit message", type: :string)

          cmd  = ["git", "commit", "-a"]
          cmd << "--allow-empty-message"      if message.nil?
          cmd += ["-m", message.shell_escape] unless message.nil?

          status = exec_cmd(cmd,
                            as_su: !existing_dir(@local_dir_path),
                            chdir: @local_dir_path)
        end
      end
    end
    status
  end

  protected def perform_fetch(remote: nil, branch: nil)
    error("Invalid remote `#{remote}`.") if remote && !remotes.include?(remote)
    error("Invalid branch `#{branch}`.") if branch && !branches.include?(branch)

    tell("Fetching information from remote", :blue)

    cmd  = ["git", "fetch"]
    cmd << remote.shell_escape unless remote.nil?
    cmd << branch.shell_escape unless branch.nil?

    exec_cmd(cmd, as_su: !existing_dir(@local_dir_path), chdir: @local_dir_path)
  end

  protected def perform_clone(recursive: true)
    tell("Syncing from remote repository: `#{@remote_normalized_url}`", :blue)

    cmd  = ["git", "clone"]
    cmd << "--recursive" if recursive
    cmd << @remote_normalized_url.shell_escape
    cmd << @local_dir_path.shell_escape

    exec_cmd(cmd, as_su: !existing_dir(@local_dir_path), chdir: @local_dir_path)
  end

  # Pull from the provided `remote` in the provided `branch`.
  #
  protected def perform_pull(remote: nil, branch: nil, with_submodules: true)
    error("Invalid remote `#{remote}`") if remote && !remotes.include?(remote)
    error("Invalid branch `#{branch}`") if branch && !branches.include?(branch)

    tell("Performing pull", :blue)

    cmd  = ["git", "pull"]
    cmd << remote.shell_escape unless remote.nil?
    cmd << branch.shell_escape unless branch.nil?

    status = exec_cmd(cmd,
                      as_su: !existing_dir(@local_dir_path),
                      chdir: @local_dir_path)

    if with_submodules
      status &&= exec_cmd(%w(git submodule update --recursive),
                          as_su: !existing_dir(@local_dir_path),
                          chdir: @local_dir_path)
    end

    status
  end

  # Push to the provided `remote` in the provided `branch`.
  #
  protected def git_push(remote: nil, branch: nil)
    error("Invalid remote `#{remote}`") if remote && !remotes.include?(remote)
    error("Invalid branch `#{branch}`") if branch && !branches.include?(branch)

    tell("Pushing to remote", :blue)

    cmd  = ["git", "push"]
    cmd << remote.shell_escape unless remote.nil?
    cmd << branch.shell_escape unless branch.nil?

    exec_cmd(cmd, as_su: !existing_dir(@local_dir_path), chdir: @local_dir_path)
  end

end
