shared_context :git do

  def repo_dir_path(repo_name)
    Pathname.new(ENV["GIT_REPOS_DIR"] || Dir.mktmpdir).join(repo_name)
  end

  def git_user
    ENV["GIT_USER"] || "git"
  end

  def git_group
    ENV["GIT_GROUP"] || "git"
  end

  def create_repo!(repo_name)
    repo_dir_path = repo_dir_path(repo_name)

    repo_dir_path.mkpath

    FileUtils.cd(repo_dir_path) do
      system "git init --bare"
    end

    FileUtils.chown_R(git_user, git_group, repo_dir_path)
  end

  def destroy_repo!(repo_name)
    repo_dir_path = repo_dir_path(repo_name)

    repo_dir_path.rmtree
  end

end
