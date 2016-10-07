require "spec_helper"


describe Fizzy::MetaInfo do

  let(:verbose) { true }

  let(:meta) {
    Fizzy::Mocks::Meta.new({
      qwe: "rty",
      features: %i(foo bar)
    })
  }

  describe "#selected_by_only?" do

    context "when truthy `only`" do
      [ # As logic expression
        "f?foo", "v?qwe", "v?qwe || v?foo",
        # As SOP array
        {features: [:foo, :baz]}, {features: [[:foo, :bar]]}, {vars: [:qwe]}
      ].each do |only|
        context "`#{only}` is provided" do
          subject { meta.selected_by_only?(only, verbose) }
          it { is_expected.to eq(true) }
        end
      end
    end

    context "when falsy `only`" do
      [ # As logic expression
        "v?foo", "f?qwe", "v?qwe && v?foo",
        # As SOP array
        {features: [:qwe, :baz]}, {features: [[:foo, :baz]]}, {vars: [:foo]}
      ].each do |only|
        context "`#{only}` is provided" do
          subject { meta.selected_by_only?(only, verbose) }
          it { is_expected.to_not eq(true) }
        end
      end
    end

  end
end
