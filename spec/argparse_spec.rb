require "spec_helper"

PARSE_FIXTURES = {
  # First argument should be the sub-command name.
  ["-v"] => { status: false, options: {} },
  ["-H", "bar"] => { status: false, options: {} },
  ["foo"] => { status: true, options: { command: "foo" } },
  ["foo", "--no-verbose"] => {
    status: true,
    options: { command: "foo", verbose: false }
  },
  ["foo", "-v"] => {
    status: true,
    options: { command: "foo", verbose: true }
  },
  ["bar"] => {
    status: false,
    options: { command: "bar", happy: true }
  },
  ["bar", "-d", "10", "--where", "/tmp"] => {
    status: true,
    options: {
      command: "bar",
      happy: true,
      delay: 10,
      where: Pathname.new("/tmp")
    }
  },
  ["bar", "--no-happy", "-d", "10"] => {
    status: true,
    options: {
      command: "bar",
      happy: false,
      delay: 10
    }
  },
  ["bar", "-v", "-d", "10"] => {
    status: true,
    options: {
      command: "bar",
      happy: true,
      delay: 10,
      verbose: true
    }
  }
}.freeze

describe(Fizzy::ArgParse::CommandParser) do
  include_context(:output)

  # before { silence_output } TODO, uncomment
  # after { enable_output }

  let(:subcommand_parsers) do
    [
      Fizzy::ArgParse::SubCommandParser.new(
        "foo",
        "this is parser for sub-command foo"
      ),
      Fizzy::ArgParse::SubCommandParser.new(
        "bar",
        "this is parser for sub-command bar",
        spec: {
          delay: {
            required: true,
            abbrev: "d",
            desc: "specify delay",
            type: Integer
          },
          mood: {
            abbrev: "m",
            desc: "specify your mood",
            type: %i[good bad]
          },
          happy: {
            abbrev: "H",
            desc: "are u happy?",
            type: :boolean,
            default: true
          },
          where: {
            desc: "where??",
            type: Pathname
          }
        }
      )
    ]
  end

  let(:command_parser) do
    Fizzy::ArgParse::RootCommandParser.new(
      "fizzy",
      subcommand_parsers: subcommand_parsers
    )
  end

  context("#parse") do
    PARSE_FIXTURES.each do |arguments, info|
      context("arguments `#{arguments}` are provided") do
        it("#{info[:status] ? "correctly" : "fails to"} parse #{arguments}") do
          expect(command_parser.parse(arguments)).to eq(info[:status])
          expect(command_parser.options).to eq(info[:options])
        end
      end
    end
  end

  context("#on_command") do
    let(:handler) { spy("handler") }
    let(:handle_proc) { proc { handler.handle } }
    let(:foo_regexp) { /^foo$/ }

    it("registers handler") do
      command_parser.on_command(foo_regexp, &handle_proc)
      foo_handlers =
        command_parser.handlers.select do |info, _|
          info[:regexp] == foo_regexp
        end
      expect(foo_handlers.length).to eq(1)
      expect(foo_handlers.values.first).to eq(handle_proc)
    end
  end

  context("#run") do
    let(:handler) { spy("handler") }

    before { command_parser.on_command(/^foo$/) { handler.handle } }

    it("calls the registered handler") do
      command_parser.parse(["foo"])
      command_parser.run
      expect(handler).to have_received(:handle)
    end
  end
end
