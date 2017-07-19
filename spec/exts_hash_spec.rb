require "spec_helper"


describe Hash do

  describe "#deep_symbolize_keys" do
    let(:expected) { { person: { name: "Rob", age: 28, eye: "blue" } } }
    subject {
      { "person" => { name: "Rob", "age" => 28, "eye" => "blue" }
      }.deep_symbolize_keys
    }

    it { is_expected.to eq(expected) }
  end

  describe "#deep_stringify_keys" do
    let(:expected) {
      { "person" => { "name" => "Rob", "age" => 28, "eye" => :blue } }
    }
    subject {
      { person: { name: "Rob", age: 28, eye: :blue }
      }.deep_stringify_keys
    }

    it { is_expected.to eq(expected) }
  end

  describe "#deep_transform_keys" do
    let(:expected) {
      { "PERSON" => { "NAME" => "Rob", "AGE" => "28", "EYE" => "blue" } }
    }
    subject {
      { person: { name: "Rob", age: "28", "EyE" => "blue" }
      }.deep_transform_keys{ |key| key.to_s.upcase }
    }

    it { is_expected.to eq(expected) }
  end

end
