#
# Main of fizzy CLI.
#
class Fizzy::CLI::Main
  include Singleton
  extend Forwardable

  attr_reader :parser

  def_delegators :parser, :parse, :run

  def initialize
    @parser = Fizzy::ArgParse::RootCommandParser.new("fizzy")
    parser.on_option(/^help$/) do
      parser.tell_help
      false
    end
  end

  def add_subcommand(subcommand)
    parser.on_command(/^#{subcommand.name}$/) do
      subcommand.run
      false
    end
    parser.add_subcommand_parser(subcommand.parser)
  end
end
