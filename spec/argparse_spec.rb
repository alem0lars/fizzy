require "spec_helper"


describe Fizzy::ArgParse::Command do

  include_context :output

  let(:command) do
    Fizzy::ArgParse::RootCommand.new("fizzy", subcommands: [
      Fizzy::ArgParse::SubCommand.new("foo", "this is sub-command foo"),
      Fizzy::ArgParse::SubCommand.new("bar", "this is sub-command bar", spec: {
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
    ])
  end

  context "#run" do
    let(:handler) { spy("handler") }
    before(:each) { command.on(/^foo$/) { handler.handle } }

    it "calls the registered handler" do
      command.parse(["foo"])
      command.run
      expect(handler).to have_received(:handle)
    end
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
        it "#{info[:status] ? "correctly" : "fails to"} parse arguments" do
          expect(command.parse(arguments)).to eq(info[:status])
          expect(command.options).to eq(info[:options])
        end
      end
    end
  end

end
