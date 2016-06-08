require "helper"

describe Hash do

  describe "#deep_symbolize_keys" do
    it "should transform every key to `Symbol`" do
      expected = {person: {name: "Rob", age: 28}}
      actual   = {"person" => {name: "Rob", "age" => 28}}
      assert_equal(expected, actual.deep_symbolize_keys)
    end
  end

  describe "#deep_stringify_keys" do
    it "should transform every key to `String`" do
      expected = {"person" => {"name" => "Rob", "age" => 28}}
      actual   = {person: {name: 'Rob', age: 28}}
      assert_equal(expected, actual.deep_stringify_keys)
    end
  end

  describe "#deep_transform_keys" do
    it "should transform every key, based on the provided block" do
      expected = {"PERSON" => {"NAME" => "Rob", "AGE" => "28"}}
      actual   = {person: {name: "Rob", age: "28"}}
      assert_equal(expected,
                   actual.deep_transform_keys{|key| key.to_s.upcase})
    end
  end

end
