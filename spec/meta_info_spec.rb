require "spec_helper"

describe Fizzy::Meta::Info do
  include_context :output

  let(:verbose) { true }

  let(:meta) do
    Fizzy::Mock::Meta.new(qwe: "rty",
                          features: %i[foo bar])
  end

  before { silence_output }
  after { enable_output }

  describe "#selected_by_only?" do
    context "when truthy `only`" do
      [ # As logic expression
        "f?foo", "v?qwe", "v?qwe || v?foo",
        # As SOP array
        { features: %i[foo baz] }, { features: [%i[foo bar]] }, { vars: [:qwe] }
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
        { features: %i[qwe baz] }, { features: [%i[foo baz]] }, { vars: [:foo] }
      ].each do |only|
        context "`#{only}` is provided" do
          subject { meta.selected_by_only?(only, verbose) }

          it { is_expected.not_to eq(true) }
        end
      end
    end
  end
end
