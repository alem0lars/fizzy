require "helper"

describe Fizzy::Sync do

  describe "#available" do
    it "should contain available synchronizers" do
      synchronizers = Fizzy::Sync.available
      synchronizers.must_be_kind_of Array
      synchronizers.wont_be_empty
    end
  end

  describe "#enabled" do
    it "should contain enabled synchronizers" do
      # When remote is `git:`, `Fizzy::Sync::Git` is enabled.
      syncs = Fizzy::Sync.enabled(Pathname.new("foo"), "git:bar")
      syncs.length.must_be :==, 1
      syncs.first.must_be_kind_of Fizzy::Sync::Git

      # When remote is an existing directory, `Fizzy::Sync::Local` is enabled.
      Dir.mktmpdir("foo") do |dir_path|
        syncs = Fizzy::Sync.enabled(Pathname.new("foo"), dir_path)
        syncs.any?{|e| e.is_a? Fizzy::Sync::Local}.must_equal true
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
