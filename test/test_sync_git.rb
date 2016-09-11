require "helper"

describe Fizzy::Sync::Git do
  include Fizzy::TestUtils::Docker
  include Fizzy::TestUtils::Git

  before do
    skip unless in_docker?

    @local_dir_path = Pathname.new(Dir.mktmpdir)

    @repo_name = "foo"
    @repo_url  = "git@localhost:#{repo_dir_path(@repo_name)}"

    create_repo! @repo_name

    @git = Fizzy::Sync::Git.new(@local_dir_path, @repo_url)
  end

  after do
    skip unless in_docker?

    @local_dir_path.rmtree
    destroy_repo! @repo_name
  end

  describe "#local_changed?" do
    before do
      @git.send(:perform_clone)
    end

    it "should return false if there aren't local modifications" do
      skip unless in_docker?

      @git.local_changed?.must_equal false
    end

    it "should return true if there are local modifications" do
      skip unless in_docker?

      @local_dir_path.join("qwerty").write("lol")
      @git.local_changed?.must_equal true
    end
  end
end
