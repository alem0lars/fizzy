shared_context :git do

  # Compute the repository base directory path from provided repository name.
  #
  def repo_dir_path(repo_name)
    Pathname.new(ENV["GIT_REPOS_DIR"] || Dir.mktmpdir).join(repo_name)
  end

  # Get UNIX user that should be used for git repositories.
  #
  def git_user
    ENV["GIT_USER"] || "git"
  end

  # Get UNIX group that should be used for git repositories.
  #
  def git_group
    ENV["GIT_GROUP"] || "git"
  end

  # Create a new (bare) repository named as `repo_name`.
  #
  def create_repo!(repo_name)
    repo_dir_path = repo_dir_path(repo_name)

    repo_dir_path.mkpath

    FileUtils.cd(repo_dir_path) do
      system "git init --bare"
    end

    FileUtils.chown_R(git_user, git_group, repo_dir_path)
  end

  # Destroy an existing repository named `repo_name`.
  #
  def destroy_repo!(repo_name)
    repo_dir_path = repo_dir_path(repo_name)

    repo_dir_path.rmtree
  end

end
