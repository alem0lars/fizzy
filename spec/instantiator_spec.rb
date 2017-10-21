require "spec_helper"

describe Fizzy::Instantiator do
  include_context :fs

  before(:each) do
    @src_dir_path = Pathname.new Dir.mktmpdir("fizzy-")
    @instance_dir_path = Pathname.new Dir.mktmpdir("fizzy-")

    mktree({
      foo: "<%= foo %>",
      bar: {
        baz: "another normal text..",
        qwe: {
          rty: "<%= var1 %> is <%= value1 %>",
          asd: "this is just normal text"
        }
      }
    }, @src_dir_path)
  end

  after(:each) do
    @src_dir_path.rmtree
    @instance_dir_path.rmtree
  end

  let(:context) { {var1: "gentoo", value1: "pwns!", foo: "bar", baz: "qwe"} }

  subject(:instantiator) do
    described_class.new(@src_dir_path, @instance_dir_path, context)
  end

  context "#instantiate" do
    subject { instantiator.instantiate }
    let(:expected) { "foo" }

    it { is_expected.to eq(expected) }
  end
end
