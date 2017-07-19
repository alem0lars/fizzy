require "spec_helper"


describe Fizzy::ArgParse::RootParser do

  include_context :output

=begin
  before(:each) { silence_output }
  after(:each) { enable_output }
=end

  let(:root_parser) { described_class.new }

  {
    ["-h"] => {help: true},
    ["foo"] => {command: "foo"},
    ["foo", "-h"] => {command: "foo", help: true},
    ["-h", "foo"] => {command: "foo", help: true}
  }.each do |arguments, options|
    context("arguments `#{arguments}` are provided") do
      subject { root_parser.parse(arguments) }
      before(:each) do
        root_parser.add_subcommand_parser(
          Fizzy::ArgParse::CommandParser.new("foo", "this is command foo")
        )
        root_parser.add_subcommand_parser(
          Fizzy::ArgParse::CommandParser.new("bar", "this is command bar", {
            delay: {
              required: true,
              abbrev: "d",
              desc: "specify delay",
              type: Fixnum
            },
            mood: {
              abbrev: "m",
              desc: "specify your mood",
              type: [:good, :bad]
            },
            happy: {
              abbrev: "H",
              desc: "specify if you are happy (or not)",
              type: :boolean
            }
          })
        )
      end
      it { is_expected.to eq(options) }
    end
  end

end
