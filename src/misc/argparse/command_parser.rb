# Base class to declare argument parsing for commands.
#
class Fizzy::ArgParse::CommandParser
  attr_reader :name, :parser, :options, :handlers

  include Fizzy::IO

  def initialize(name)
    @name     = name.to_s
    @options  = {}
    @handlers = {}
  end

  def parse(args)
    args = args.dup
    parse!(args)
    true
  rescue StandardError => error
    error(error.to_s.capitalize, exc: nil)
    tell_help
    false
  end

  def parse!(args)
    error "Abstract method called with: #{args}."
  end

  def help
    parser.banner = banner
    parser.to_s
  end

  def tell_help
    tell(help)
  end

  def inspect
    "#{self.class.name}(name=#{name})"
  end

  alias to_s inspect

  protected

    def banner
      error "Abstract method called"
    end
end
