# Namespace for fizzy commandline interface.
#
module Fizzy::CLI
  # Main of fizzy CLI.
  #
  class Main
    extend Forwardable

    attr_reader :root_command

    def_delegators :root_command, :parse, :run

    def initialize
      @root_command = Fizzy::ArgParse::RootCommand.new("fizzy")
    end
  end

  def self.create
    Fizzy::CLI::Main.new
  end
end
