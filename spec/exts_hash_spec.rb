require "spec_helper"


describe Hash do

  describe "#deep_symbolize_keys" do
    subject {
      { "person" => { name: "Rob", "age" => 28, "eye" => "blue" }
      }.deep_symbolize_keys
    }

    let(:expected) { { person: { name: "Rob", age: 28, eye: "blue" } } }

    it { is_expected.to eq(expected) }
  end

  describe "#deep_stringify_keys" do
    subject {
      { person: { name: "Rob", age: 28, eye: :blue }
      }.deep_stringify_keys
    }

    let(:expected) {
      { "person" => { "name" => "Rob", "age" => 28, "eye" => :blue } }
    }

    it { is_expected.to eq(expected) }
  end

  describe "#deep_transform_keys" do
    subject {
      { person: { name: "Rob", age: "28", "EyE" => "blue" }
      }.deep_transform_keys{ |key| key.to_s.upcase }
    }

    let(:expected) {
      { "PERSON" => { "NAME" => "Rob", "AGE" => "28", "EYE" => "blue" } }
    }

    it { is_expected.to eq(expected) }
  end

end
