require "spec_helper"

describe Fizzy::Diff::Generator do
  let(:previous_string) { "foo\nbar\nbaz\nqwe" }
  let(:current_string)  { "foo foo\nbaz\nbar\nbaz" }
  let(:diff_generator) { described_class.new(previous_string, current_string) }

  context("#generate_diff") do
    let(:expected) {
      [
        Fizzy::Diff::Line.new(:del, 1,   nil, "foo\n"),
        Fizzy::Diff::Line.new(:del, 2,   nil, "bar\n"),
        Fizzy::Diff::Line.new(:ins, nil, 1,   "foo foo\n"),
        Fizzy::Diff::Line.new(:eql, 3,   2,   "baz\n"),
        Fizzy::Diff::Line.new(:del, 4,   nil, "qwe"),
        Fizzy::Diff::Line.new(:ins, nil, 3,   "bar\n"),
        Fizzy::Diff::Line.new(:ins, nil, 4,   "baz")
      ]
    }
    subject { diff_generator.generate_diff }

    it { is_expected.to eq(expected) }
  end

  context("#generate_diff_str") do
    let(:expected) {
      [
        "{r{-    1         foo}}",
        "{r{-    2         bar}}",
        "{g{+         1    foo foo}}",
        "{b{     3    2    baz}}",
        "{r{-    4         qwe}}",
        "{g{+         3    bar}}",
        "{g{+         4    baz}}",
      ].join("\n")
    }
    subject { described_class.diff_to_str(diff_generator.generate_diff) }

    it { is_expected.to eq(expected) }
  end

end
