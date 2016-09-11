module Fizzy::TestUtils::Git

  def repo_dir_path(repo_name)
    Pathname.new(ENV["GIT_REPOS_DIR"] || Dir.mktmpdir).join("#{repo_name}.git")
  end

  def create_repo!(repo_name)
    repo_dir_path = repo_dir_path(repo_name)

    repo_dir_path.dirname.mkpath

    FileUtils.cd(repo_dir_path.dirname) do
      system "git init --bare #{repo_dir_path.basename}"
    end
  end

  def destroy_repo!(repo_name)
    repo_dir_path = repo_dir_path(repo_name)

    repo_dir_path.rmtree
  end

end
