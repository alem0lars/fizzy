require "spec_helper"


describe Fizzy::Tree::Node do

  shared_examples_for "any detached node" do
    it { is_expected.not_to eq(Object.new) }
    it { is_expected.not_to eq(1) }
    it { is_expected.to be_root }
    it { is_expected.to have_attributes(parent: nil) }
  end

  describe "#initialize" do
    context "with empty name and `nil` content" do
      subject { described_class.new("") }

      it { is_expected.to have_attributes(name: "", content: nil) }

      it_behaves_like "any detached node"
    end

    context "with name `'A'` and `nil` content" do
      subject { described_class.new("A") }

      it { is_expected.to have_attributes(name: "A", content: nil) }

      it_behaves_like "any detached node"
    end

    context "with node name `'A'` and some content" do
      let(:sample) { "sample" }
      subject { described_class.new("A", sample) }

      it { is_expected.to have_attributes(name: "A", content: sample) }

      it_behaves_like "any detached node"
    end
  end
end
