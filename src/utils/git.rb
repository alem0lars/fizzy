module Fizzy::Git

  include Fizzy::IO
  include Fizzy::Execution
  include Fizzy::Filesystem

  def git_info(git_root_path)
    info = nil
    FileUtils.cd(git_root_path) do
      info = {
        local:  `git rev-parse @`.strip,
        remote: `git rev-parse @{u}`.strip,
        base:   `git merge-base @ @{u}`.strip
      }
    end
    info
  end

  def git_local_changes(git_root_path)
    `git status -uall --porcelain`.strip
  end

  def git_remotes
    `git remote`.split(/\W+/).reject(&:empty?)
  end

  def git_branches
    `git branch`.split(/\W+/).reject(&:empty?)
  end

  def git_has_local_changes(git_root_path)
    !git_local_changes(git_root_path).empty?
  end

  def git_should_pull(git_root_path)
    info = git_info(git_root_path)
    info[:remote] != info[:base]
  end

  def git_should_push(git_root_path)
    info = git_info(git_root_path)
    info[:local] != info[:base]
  end

  def git_pull(remote: nil, branch: nil, with_submodules: true)
    error("Invalid remote `#{remote}`.") \
      if remote && !git_remotes.include?(remote)
    error("Invalid branch `#{branch}`.") \
      if branch && !git_branches.include?(branch)

    tell("Performing pull.", :blue)

    cmd  = "git pull"
    cmd << " #{Shellwords.escape(remote)}" unless remote.nil?
    cmd << " #{Shellwords.escape(branch)}" unless branch.nil?

    status   = exec_cmd(cmd, as_su: !existing_dir(Pathname.pwd))
    status &&= exec_cmd("git submodule update --recursive",
                        as_su: !existing_dir(Pathname.pwd)) if with_submodules

    status
  end

  def git_clone(url, dst_path, recursive: true)
    error("Invalid url: can't be empty.") if url.nil?
    url = git_normalize_url(url)
    tell("Syncing from remote repo: `#{url}`.", :blue)

    cmd  = "git clone"
    cmd << " --recursive" if recursive
    cmd << " #{Shellwords.escape(url)} #{Shellwords.escape(dst_path)}"

    exec_cmd(cmd, as_su: !existing_dir(dst_path.dirname))
  end

  def git_push(remote: nil, branch: nil)
    error("Invalid remote `#{remote}`.") \
      if remote && !git_remotes.include?(remote)
    error("Invalid branch `#{branch}`.") \
      if branch && !git_branches.include?(branch)

    tell("Pushing to remote.", :blue)

    cmd  = "git push"
    cmd << " #{Shellwords.escape(remote)}" unless remote.nil?
    cmd << " #{Shellwords.escape(branch)}" unless branch.nil?

    exec_cmd(cmd, as_su: !existing_dir(Pathname.pwd))
  end

  def git_fetch(remote: nil, branch: nil)
    error("Invalid remote `#{remote}`.") \
      if remote && !git_remotes.include?(remote)
    error("Invalid branch `#{branch}`.") \
      if branch && !git_branches.include?(branch)

    tell("Fetching from remote.", :blue)

    cmd  = "git fetch"
    cmd << " #{Shellwords.escape(remote)}" unless remote.nil?
    cmd << " #{Shellwords.escape(branch)}" unless branch.nil?

    exec_cmd(cmd, as_su: !existing_dir(Pathname.pwd))
  end

  def git_add(files: nil)
    error("Invalid files `#{files}`.") unless files.nil? || files.is_a?(Array)

    cmd  = "git add"
    if files.nil?
      cmd << " -A"
    else
      cmd << files.map { |f| Shellwords.escape(f) }.join(" ")
    end

    exec_cmd(cmd, as_su: !existing_dir(Pathname.pwd))
  end

  def git_commit(message: nil)
    tell("Performing commit.", :blue)

    cmd = "git commit -a"
    if message.nil?
      cmd << " --allow-empty-message"
    else
      cmd << " -m #{Shellwords.escape(message)}"
    end

    exec_cmd(cmd, as_su: !existing_dir(Pathname.pwd))
  end

  def git_normalize_url(url, default_protocol: "ssh")
    protocols = %w(https ssh)
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
    case md[:protocol] || default_protocol
    when "ssh"   then "git@github.com:#{md[:username]}/#{md[:repository]}"
    when "https" then "https://github.com/#{md[:username]}/#{md[:repository]}"
    else error("Invalid protocol for `#{url}`: " +
               "not in `[#{protocols.join(", ")}]`.")
    end
  end

end
