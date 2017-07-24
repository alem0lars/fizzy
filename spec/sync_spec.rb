require "spec_helper"

describe Fizzy::Sync do
  include_context :docker

  describe ".available" do
    subject { described_class.available }

    it { is_expected.to be_kind_of(Array) }
    it { is_expected.not_to be_empty }
  end

  describe ".enabled" do
    context "when remote starts with `git:`" do
      subject { described_class.enabled(Pathname.new("foo"), "git:bar") }

      it { expect(subject.size).to eq(1) }
      it { expect(subject.first).to be_kind_of(Fizzy::Sync::Git) }
    end

    context "when local is a git repository" do
      just_in_docker do
        subject { described_class.enabled(local_dir_path, nil) }

        let(:local_dir_path) { Pathname.new(Dir.mktmpdir) }

        before { local_dir_path.join(".git").mkpath }
        after { FileUtils.rm_r(local_dir_path) }
        it { is_expected.to include(a_kind_of(Fizzy::Sync::Git)) }
      end
    end

    context "when remote is an existing directory" do
      just_in_docker do
        subject { described_class.enabled(Pathname.new("foo"), remote_url) }

        let(:remote_url) { Pathname.new(Dir.mktmpdir) }

        after { FileUtils.rm_r(remote_url) }
        it { is_expected.to include(a_kind_of(Fizzy::Sync::Local)) }
      end
    end
  end

  describe ".selected" do
    context "when a remote url" do
      %w[git:foobar foobar].each do |remote_url|
        context "`#{remote_url}` that selects `git` sync is provided" do
          subject { described_class.selected(Pathname.new("foo"), remote_url) }

          it { is_expected.to be_kind_of(Fizzy::Sync::Git) }
        end
      end

      context "that selects `local` sync is provided" do
        just_in_docker do
          subject { described_class.selected(Pathname.new("foo"), dir_path) }

          let(:dir_path) { Pathname.new(Dir.mktmpdir) }

          after { FileUtils.rm_r(dir_path) }
          it { is_expected.to be_kind_of(Fizzy::Sync::Local) }
        end
      end
    end
  end
end
