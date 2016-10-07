require "spec_helper"


describe Fizzy::Sync do

  describe "#available" do
    subject { Fizzy::Sync.available }
    it { is_expected.to be_kind_of(Array) }
    it { is_expected.to_not be_empty }
  end

  describe "#enabled" do
    context "when remote starts with `git:`" do
      subject { Fizzy::Sync.enabled(Pathname.new("foo"), "git:bar") }
      it { is_expected.to have(1).items }
      it { is_expected.to be_kind_of(Fizzy::Sync::Git) }
    end

    context "when remote is an existing directory" do
      before do
        @dir_path = Dir.mktmpdir("foo")
      end

      after do
        FileUtils.rm_R(@dir_path)
      end

      subject { Fizzy::Sync.enabled(Pathname.new("foo"), @dir_path) }
      it { is_expected.to include(a_kind_of Fizzy::Sync::Local) }
      end
    end
  end

  describe "#selected" do
    it do
      %w(git:foobar foobar).each do |remote_url|
        sync = Fizzy::Sync.selected(Pathname.new("foo"), remote_url)
        sync.must_be_kind_of Fizzy::Sync::Git
      end

      Dir.mktmpdir("foo") do |dir_path|
        sync = Fizzy::Sync.selected(Pathname.new("foo"), dir_path)
        sync.must_be_kind_of Fizzy::Sync::Local
      end
    end
  end

end
