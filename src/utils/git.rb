module Fizzy::Utils

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

  def git_pull(with_submodules: true)
    say 'Performing pull.', :cyan
    status = exec_cmd('git pull origin master',
                      as_su: !existing_dir(Dir.pwd))
    if with_submodules
      status &&= exec_cmd('git submodule foreach git checkout master',
                          as_su: !existing_dir(Dir.pwd))
      status &&= exec_cmd('git submodule foreach git merge origin/master',
                          as_su: !existing_dir(Dir.pwd))
    end
    status
  end

  def git_clone(url, dst_path, recursive: true)
    error("Invalid url: can't be empty.") if url.nil?
    say "Syncing from remote repo: `#{url}`.", :blue
    cmd = if recursive
            "git clone --recursive \"#{url}\" \"#{dst_path}\""
          else
            "git clone \"#{url}\" \"#{dst_path}\""
          end
    exec_cmd(cmd, :as_su => !existing_dir(File.dirname(dst_path)))
  end

end
