require "spec_helper"


describe Fizzy::Sync do

  include_context :docker

  describe "#available" do
    subject { Fizzy::Sync.available }
    it { is_expected.to be_kind_of(Array) }
    it { is_expected.to_not be_empty }
  end

  describe "#enabled" do
    context "when remote starts with `git:`" do
      subject { Fizzy::Sync.enabled(Pathname.new("foo"), "git:bar") }
      it { expect(subject.size).to eq(1) }
      it { expect(subject.first).to be_kind_of(Fizzy::Sync::Git) }
    end

    context "when remote is an existing directory" do
      just_in_docker do
        let(:dir_path) { Pathname.new(Dir.mktmpdir) }

        after(:each) do
          FileUtils.rm_r(dir_path)
        end

        subject { Fizzy::Sync.enabled(Pathname.new("foo"), dir_path) }
        it { is_expected.to include(a_kind_of Fizzy::Sync::Local) }
      end
    end
  end

  describe "#selected" do
    context "when a remote url" do
      %w(git:foobar foobar).each do |remote_url|
        context "`#{remote_url}` that selects `git` sync is provided" do
          subject { Fizzy::Sync.selected(Pathname.new("foo"), remote_url) }
          it { is_expected.to be_kind_of(Fizzy::Sync::Git) }
        end
      end

      context "that selects `local` sync is provided" do
        just_in_docker do
          let(:dir_path) {
            puts "A" * 80
            Pathname.new(Dir.mktmpdir("foo")) }

          after(:each) do
            puts "B" * 80
            FileUtils.rm_r(dir_path)
          end

          subject {
            puts "D" * 80
            Fizzy::Sync.selected(Pathname.new("foo"), dir_path)
          }
          it {
            puts "C" * 80
            is_expected.to be_kind_of(Fizzy::Sync::Local)
          }
        end
      end
    end
  end

end
