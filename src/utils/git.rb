module Fizzy::Git

  def git_info(git_root_path)
    info = nil
    FileUtils.cd(git_root_path) do
      info = {
        :local  => `git rev-parse @`.strip,
        :remote => `git rev-parse @{u}`.strip,
        :base   => `git merge-base @ @{u}`.strip
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
    error("Invalid remote `#{remote}`.") if remote && !git_remotes.include?(remote)
    error("Invalid branch `#{branch}`.") if branch && !git_branches.include?(branch)

    say "Performing pull.", :blue

    cmd  = "git pull"
    cmd << " #{Shellwords.escape(remote)}" unless remote.nil?
    cmd << " #{Shellwords.escape(branch)}" unless branch.nil?

    status   = exec_cmd(cmd, as_su: !existing_dir(Dir.pwd))
    status &&= exec_cmd("git submodule update --recursive",
                        as_su: !existing_dir(Dir.pwd)) if with_submodules

    status
  end

  def git_clone(url, dst_path, recursive: true)
    error("Invalid url: can't be empty.") if url.nil?
    say "Syncing from remote repo: `#{url}`.", :blue

    cmd  = "git clone"
    cmd << " --recursive" if recursive
    cmd << " #{Shellwords.escape(url)} #{Shellwords.escape(dst_path)}"

    exec_cmd(cmd, :as_su => !existing_dir(File.dirname(dst_path)))
  end

  def git_push(remote: nil, branch: nil)
    error("Invalid remote `#{remote}`.") if remote && !git_remotes.include?(remote)
    error("Invalid branch `#{branch}`.") if branch && !git_branches.include?(branch)

    say "Pushing to remote.", :blue

    cmd  = "git push"
    cmd << " #{Shellwords.escape(remote)}" unless remote.nil?
    cmd << " #{Shellwords.escape(branch)}" unless branch.nil?

    exec_cmd(cmd, as_su: !existing_dir(Dir.pwd))
  end

  def git_fetch(remote: nil, branch: nil)
    error("Invalid remote `#{remote}`.") if remote && !git_remotes.include?(remote)
    error("Invalid branch `#{branch}`.") if branch && !git_branches.include?(branch)

    say "Fetching from remote.", :blue

    cmd  = "git fetch"
    cmd << " #{Shellwords.escape(remote)}" unless remote.nil?
    cmd << " #{Shellwords.escape(branch)}" unless branch.nil?

    exec_cmd(cmd, as_su: !existing_dir(Dir.pwd))
  end

  def git_add(files: nil)
    error("Invalid files `#{files}`.") unless files.nil? || files.is_a?(Array)

    cmd  = "git add"
    if files.nil?
      cmd << " -A"
    else
      cmd << files.map { |f| Shellwords.escape(f) }.join(" ")
    end

    exec_cmd(cmd, as_su: !existing_dir(Dir.pwd))
  end

  def git_commit(message: nil)
    say "Performing commit.", :blue

    cmd = "git commit -a"
    if message.nil?
      cmd << " --allow-empty-message"
    else
      cmd << " -m #{Shellwords.escape(message)}"
    end

    exec_cmd(cmd, as_su: !existing_dir(Dir.pwd))
  end

end
