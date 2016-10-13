require "spec_helper"


# TODO: Use shared examples (if it makes sense)
describe Fizzy::Sync do

  include_context :docker

  describe ".available" do
    subject { Fizzy::Sync.available }
    it { is_expected.to be_kind_of(Array) }
    it { is_expected.to_not be_empty }
  end

  describe ".enabled" do
    context "when remote starts with `git:`" do
      subject { Fizzy::Sync.enabled(Pathname.new("foo"), "git:bar") }
      it { expect(subject.size).to eq(1) }
      it { expect(subject.first).to be_kind_of(Fizzy::Sync::Git) }
    end

    context "when local is a git repository" do
      just_in_docker do
        let(:local_dir_path) { Pathname.new(Dir.mktmpdir) }
        before(:each) { local_dir_path.join(".git").mkpath }
        after(:each) { FileUtils.rm_r(local_dir_path) }
        subject { Fizzy::Sync.enabled(local_dir_path, nil) }
        it { is_expected.to include(a_kind_of Fizzy::Sync::Git) }
      end
    end

    context "when remote is an existing directory" do
      just_in_docker do
        let(:remote_url) { Pathname.new(Dir.mktmpdir) }
        after(:each) { FileUtils.rm_r(remote_url) }
        subject { Fizzy::Sync.enabled(Pathname.new("foo"), remote_url) }
        it { is_expected.to include(a_kind_of Fizzy::Sync::Local) }
      end
    end
  end

  describe ".selected" do
    context "when a remote url" do
      %w(git:foobar foobar).each do |remote_url|
        context "`#{remote_url}` that selects `git` sync is provided" do
          subject { Fizzy::Sync.selected(Pathname.new("foo"), remote_url) }
          it { is_expected.to be_kind_of(Fizzy::Sync::Git) }
        end
      end

      context "that selects `local` sync is provided" do
        just_in_docker do
          let(:dir_path) { Pathname.new(Dir.mktmpdir) }
          after(:each) { FileUtils.rm_r(dir_path) }
          subject { Fizzy::Sync.selected(Pathname.new("foo"), dir_path) }
          it { is_expected.to be_kind_of(Fizzy::Sync::Local) }
        end
      end
    end
  end

end
