# Main of fizzy CLI.
#
class Fizzy::CLI::Main
  include Singleton
  extend Forwardable

  attr_reader :root_command

  def_delegators :root_command, :parse, :run

  def initialize
    @root_command = Fizzy::ArgParse::RootCommand.new("fizzy")
  end

  def add_command(command)
    root_command.add_subcommand(command)
  end
end
