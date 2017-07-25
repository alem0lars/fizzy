#
# Base class for CLI commands.
#
class Fizzy::CLI::Command
  extend Forwardable

  include Fizzy::Environment
  include Fizzy::Execution
  include Fizzy::Filesystem
  include Fizzy::Environment
  include Fizzy::Execution
  include Fizzy::Filesystem
  include Fizzy::IO
  include Fizzy::Vars
  include Fizzy::Locals
  include Fizzy::Meta::Info
  include Fizzy::Meta::Elements
  include Fizzy::IO
  include Fizzy::Vars
  include Fizzy::Locals
  include Fizzy::Meta::Info
  include Fizzy::Meta::Elements

  attr_reader :parser

  def_delegators :parser, :name, :options

  class << self
    def inherited(klass)
      available.add(klass)
    end

    def available
      @available ||= Set.new
    end
  end

  def initialize(name, desc, spec)
    @parser = Fizzy::ArgParse::SubCommandParser.new(name, desc, spec)
  end

  def run
    error("Abstract method called")
  end
end
