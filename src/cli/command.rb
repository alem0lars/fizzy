# Base class for CLI commands.
#
class Fizzy::CLI::Command
  include Fizzy::IO
  extend Forwardable

  attr_reader :command

  def_delegators :command, :name

  def initialize(name, desc, spec)
    @command = Fizzy::ArgParse::SubCommand.new(name, desc, spec)
    Main.instance.add_subcommand(command)
    Main.instance.on(/^#{name}$/, run)
  end

  def run
    error "Abstract method called"
  end
end
