require "spec_helper"


# TODO: Use shared examples (if it makes sense)
describe Fizzy::Sync::Git do

  include_context :docker
  include_context :git

  just_in_docker do

    let(:local_dir_path) { Pathname.new(Dir.mktmpdir) }

    let(:repo_name) { "foo" }
    let(:repo_url) { "#{git_user}@localhost:#{repo_dir_path(repo_name)}" }

    let(:git) { Fizzy::Sync::Git.new(local_dir_path, repo_url) }

    before(:each) do
      create_repo! repo_name
    end

    after(:each) do
      local_dir_path.rmtree
      destroy_repo! repo_name
    end

    describe "#local_changed?" do
      subject { git.local_changed? }

      before(:each) { git.send :perform_clone }

      context "when there aren't local modifications" do
        it { is_expected.to eq(false) }
      end

      context "when there are local modifications" do
        before(:each) { local_dir_path.join("qwerty").write("lol") }
        it { is_expected.to eq(true) }
      end
    end

    describe "#working_tree_changes?" do
      before(:each) { git.send :perform_clone }

      subject { git.send :working_tree_changes? }

      context "when there aren't local modifications" do
        it { is_expected.to eq(false) }
      end

      context "when there are local modifications" do
        before(:each) { local_dir_path.join("foo").write("foo") }
        it { is_expected.to eq(true) }

        context "and commit is performed" do
          before(:each) { git.send :perform_commit, message: "xD" }
          it { is_expected.to eq(false) }

          context "and then another file is added" do
            before(:each) { local_dir_path.join("bar").write("bar") }
            it { is_expected.to eq(true) }
          end
        end
      end
    end
  end
end
