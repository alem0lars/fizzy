require "spec_helper"


# TODO: Better spec (migrate to `it.is_expected`).
describe Fizzy::Tree::Node do

  shared_examples_for "any detached node" do
    it 'should not equal "Object.new"' do
      expect(tree).not_to eq(Object.new)
    end

    it "should not equal 1 or any other fixnum" do
      expect(tree).not_to eq(1)
    end

    it "identifies itself as a root node" do
      expect(tree.is_root?).to eq(true)
    end

    it "does not have a parent node" do
      expect(tree.parent).to eq(nil)
    end
  end

  describe "#initialize" do
    context "with empty name and `nil` content" do
      let (:tree) { described_class.new("") }

      it "creates the tree node with name as ''" do
        expect(tree.name).to eq("")
      end

      it "has `nil` content" do
        expect(tree.content).to eq(nil)
      end

      it_behaves_like "any detached node"
    end

    context "with name `'A'` and `nil` content" do
      let (:tree) { described_class.new("A") }

      it "creates the tree node with name as `'A'`" do
        expect(tree.name).to eq("A")
      end

      it "has `nil` content" do
        expect(tree.content).to eq(nil)
      end

      it_behaves_like "any detached node"
    end

    context "with node name `'A'` and some content" do
      let(:sample) { "sample" }
      let(:tree)   { described_class.new("A", "sample") }

      it "creates the tree node with name as `'A'`" do
        expect(tree.name).to eq("A")
      end

      it "has some content" do
        expect(tree.content).to eq(sample)
      end

      it_behaves_like "any detached node"
    end
  end
end
