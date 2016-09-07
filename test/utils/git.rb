module Fizzy::TestUtils::Git

  def create_repo(repo_name)
    base_dir_path = ENV["GIT_REPOS_DIR"] || Dir.mktmpdir
    repo_dir_path = Pathname.new(base_dir_path).join("#{repo_name}.git")

    repo_dir_path.dirname.mkdir_p

    FileUtils.cd(repo_dir_path.dirname) do
      system "git init --bare #{repo_dir_path.basename}"
    end
  end

end
