#
# Main of fizzy CLI.
#
class Fizzy::CLI::Main
  include Singleton
  extend Forwardable

  attr_reader :parser

  def_delegators :parser, :parse, :run, :tell_help, :help

  def initialize
    @parser = Fizzy::ArgParse::RootCommandParser.new("fizzy")
  end

  def add_subcommand(subcommand)
    parser.on_command(/^#{subcommand.name}$/) do
      subcommand.run
      false
    end
    parser.add_subcommand_parser(subcommand.parser)
  end
end
