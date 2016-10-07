require "spec_helper"


# describe Fizzy::Sync::Git do

#   include_context :docker
#   include_context :git

#   # skip unless in_docker?

#   let(:local_dir_path) { Pathname.new(Dir.mktmpdir) }

#   let(:repo_name) { "foo" }
#   let(:repo_url) { "#{git_user}@localhost:#{repo_dir_path(repo_name)}" }

#   let(:git) { Fizzy::Sync::Git.new(local_dir_path, repo_url) }

#   before(:each) do
#     create_repo! repo_name
#   end

#   after(:each) do
#     local_dir_path.rmtree
#     destroy_repo! repo_name
#   end

#   describe "#local_changed?" do
#     before(:each) do
#       git.perform_clone
#     end

#     it "should return false if there aren't local modifications" do
#       git.local_changed?.must_equal false
#     end

#     it "should return true if there are local modifications" do
#       local_dir_path.join("qwerty").write("lol")
#       git.local_changed?.must_equal true
#     end
#   end

#   describe "#working_tree_changes?" do
#     before(:each) do
#       git.perform_clone
#     end

#     it "should return false if there aren't local modifications" do
#       git.working_tree_changes?.must_equal false
#     end

#     it "should return true if there are local modifications" do
#       local_dir_path.join("foo").write("foo")
#       git.working_tree_changes?.must_equal true
#       git.perform_commit message: "Added foo!"
#       git.working_tree_changes?.must_equal false
#       local_dir_path.join("bar").write("bar")
#       git.working_tree_changes?.must_equal true
#     end
#   end
# end
