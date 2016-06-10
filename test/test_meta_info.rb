require "helper"

describe Fizzy::MetaInfo do

  before do
    @verbose = true
    @meta = Fizzy::Mocks::Meta.new({
      qwe: "rty",
      features: %i(foo bar)
    })
  end

  describe "#selected_by_only?" do
    it "should match" do
      assert(@meta.selected_by_only?("f?foo", @verbose))
      assert(@meta.selected_by_only?("v?qwe", @verbose))
      assert(@meta.selected_by_only?("v?qwe || v?foo", @verbose))

      assert(@meta.selected_by_only?({features: [:foo, :baz]}, @verbose))
      assert(@meta.selected_by_only?({vars: [:qwe]}, @verbose))
    end

    it "shouldn't match" do
      assert(!@meta.selected_by_only?("v?foo", @verbose))
      assert(!@meta.selected_by_only?("v?qwe && v?foo", @verbose))

      assert(!@meta.selected_by_only?({vars: [:foo]}, @verbose))
    end
  end

end
