require "spec_helper"


describe Hash do

  describe "#magic_merge" do
    let(:first)    { { a: 1, b: { c: 2, d: 0, e: [0,    5] }, f: 0       } }
    let(:second)   { {       b: {       d: 3, e: [   4, 5] }, f: 6, e: 7 } }
    let(:expected) { { a: 1, b: { c: 2, d: 3, e: [0, 4, 5] }, f: 6, e: 7 } }
    subject { first.magic_merge(second) }
    it { is_expected.to eq(expected) }
  end

  describe "#magic_merge!" do
    let(:first)    { { a: 1, b: { c: 2, d: 0, e: [0,    5] }, f: 0       } }
    let(:second)   { {       b: {       d: 3, e: [   4, 5] }, f: 6, e: 7 } }
    let(:expected) { { a: 1, b: { c: 2, d: 3, e: [0, 4, 5] }, f: 6, e: 7 } }
    subject { first.magic_merge!(second) }
    it { is_expected.to eq(expected) }
    it { expect { first.to eq(expected) } }
  end


  describe "#deep_merge" do
    let(:first)    { { a: 1, b: { c: 2, d: 0, e: [0, 5] }, f: 0       } }
    let(:second)   { {       b: {       d: 3, e: [4, 5] }, f: 6, e: 7 } }
    let(:expected) { { a: 1, b: { c: 2, d: 3, e: [4, 5] }, f: 6, e: 7 } }
    subject { first.deep_merge(second) }
    it { is_expected.to eq(expected) }
  end

  describe "#deep_merge!" do
    let(:first)    { { a: 1, b: { c: 2, d: 0, e: [0, 5] }, f: 0       } }
    let(:second)   { {       b: {       d: 3, e: [4, 5] }, f: 6, e: 7 } }
    let(:expected) { { a: 1, b: { c: 2, d: 3, e: [4, 5] }, f: 6, e: 7 } }
    subject { first.deep_merge!(second) }
    it { is_expected.to eq(expected) }
    it { expect { first.to eq(expected) } }
  end

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
