require "spec_helper"

describe(Fizzy::ArgParse::Command) do
  include_context(:output)

  before { silence_output }
  after { enable_output }

  let(:subcommands) do
    [
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
                                      })
    ]
  end

  let(:command) do
    Fizzy::ArgParse::RootCommand.new("fizzy", subcommands: subcommands)
  end

  context("#parse") do
    {
      # First argument should be the sub-command name.
      ["-h"] => { status: false, options: {} },
      ["-h", "-v"] => { status: false, options: {} },
      ["-h", "foo"] => { status: false, options: {} },
      ["foo"] => { status: true, options: { command: "foo" } },
      ["foo", "--no-verbose"] => {
        status: true,
        options: { command: "foo", verbose: false }
      },
      ["foo", "-h"] => {
        status: true, options: { command: "foo", help: true }
      },
      ["bar"] => {
        status: false, options: { command: "bar", happy: true }
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
      ["bar", "-h", "-d", "10"] => {
        status: true,
        options: {
          command: "bar",
          happy: true,
          delay: 10,
          help: true
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
    }.each do |arguments, info|
      context("arguments `#{arguments}` are provided") do
        it("#{info[:status] ? "correctly" : "fails to"} parse #{arguments}") do
          expect(command.parse(arguments)).to eq(info[:status])
          puts command.options # TODO, remove
          expect(command.options).to eq(info[:options])
        end
      end
    end
  end

  context("#on") do
    let(:handler) { spy("handler") }
    let(:handle_proc) { proc { handler.handle } }
    let(:foo_regexp) { /^foo$/ }

    it("registers handler") do
      command.on(foo_regexp, &handle_proc)
      expect(command.handlers[foo_regexp]).to eq(handle_proc)
    end
  end

  context("#run") do
    let(:handler) { spy("handler") }

    before { command.on(/^foo$/) { handler.handle } }

    it("calls the registered handler") do
      command.parse(["foo"])
      command.run
      expect(handler).to have_received(:handle)
    end
  end
end
