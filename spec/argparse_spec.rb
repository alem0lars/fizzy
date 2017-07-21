require "spec_helper"


describe Fizzy::ArgParse::Command do

  include_context :output

  let(:command) { Fizzy::ArgParse::RootCommand.new("fizzy") }

  context "#on" do
    # TODO
  end

  context "#parse" do
    {
      ["-h"] => {status: true, options: {help: true}},
      ["-h", "-v"] => {status: true, options: {help: true, verbose: true}},
      ["foo"] => {status: true, options: {command: "foo"}},
      ["foo", "--no-verbose"] => {status: true, options: {command: "foo", verbose: false}},
      ["foo", "-h"] => {status: true, options: {command: "foo", help: true}},
      ["-h", "foo"] => {status: true, options: {command: "foo", help: true}},
      ["bar"] => {status: false, options: {command: "bar"}}
    }.each do |arguments, info|
      context("arguments `#{arguments}` are provided") do
        subject { command.parse(arguments) }

        before(:each) do
          command.add_subcommand(
            Fizzy::ArgParse::SubCommand.new("foo", "this is sub-command foo")
          )
          command.add_subcommand(
            Fizzy::ArgParse::SubCommand.new("bar", "this is sub-command bar", {
              delay: {
                required: true,
                abbrev: "d",
                desc: "specify delay",
                type: Integer
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

        it { is_expected.to eq(info[:status]) }
        it { expect(command.options).to eq(info[:options]) }
      end
    end
  end

end
