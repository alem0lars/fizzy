#
# Error representing an invalid subcommand name has been specified.
#
class Fizzy::ArgParse::InvalidSubCommandName < StandardError
  attr_reader :name

  def initialize(name)
    super("Invalid sub-command named #{name}")
    @name = name
  end
end

#
# Error representing subcommand name hasn't been specified.
#
class Fizzy::ArgParse::NoSubCommandName < StandardError
  def initialize
    super("No sub-command name given")
  end
end

#
# Root command, as a composite of sub-commands and some basic global parameters.
#
class Fizzy::ArgParse::RootCommandParser < Fizzy::ArgParse::CommandParser
  attr_reader :subcommand_parsers

  def initialize(name, subcommand_parsers: [])
    super(name)

    @subcommand_parsers = subcommand_parsers
    @parser = OptionParser.new
  end

  #
  # Register a handler matching command name.
  #
  def on_command(command_name, &block)
    handlers[{ regexp: command_name, type: :command_name }] = block
  end

  #
  # Register a handler matching options.
  #
  def on_option(opt_name, opt_value = nil, &block)
    handlers[{ regexp: opt_name, type: :option_name }] = block
    handlers[{ regexp: opt_value, type: :option_value }] = block if opt_value
  end

  #
  # Run matching handlers if they match sub-command.
  #
  def run
    handlers.each do |info, handler|
      matches =
        case info[:type]
        when :option_name  then options.any? { |n, _| info[:regexp] =~ n }
        when :option_value then options.any? { |_, v| info[:regexp] =~ v }
        when :command_name then info[:regexp] =~ options[:command]
        end
      break if matches && handler.call(options)
    end
  end

  def parse!(args)
    subcommand_name = args.shift
    if subcommand_name.nil?
      error(nil, silent: true, exc: Fizzy::ArgParse::NoSubCommandName)
    end
    subcommand_parser = find_subcommand_parser(subcommand_name)
    if subcommand_parser.nil?
      error(subcommand_name,
            silent: true,
            exc: Fizzy::ArgParse::InvalidSubCommandName)
    end

    parse_subcommand_arguments(subcommand_parser, args)
  end

  def tell_help(subcommand_name = nil)
    subcommand_name ||= options[:command]
    if subcommand_name
      find_subcommand_parser(subcommand_name).tell_help
    else
      super()
    end
  end

  def add_subcommand_parser(subcommand_parser)
    subcommand_parsers << subcommand_parser
  end

  def banner
    [
      "Usage: #{name} #{options[:command] || "[subcommand]"} [options]",
      "Available sub-commands: #{subcommand_parsers.map(&:name).join(", ")}"
    ].join("\n")
  end
  protected :banner

  def find_subcommand_parser(subcommand_name = nil)
    subcommand_name ||= options[:command]
    matching_subcommand_parsers =
      subcommand_parsers.select do |c|
        c.name == subcommand_name
      end
    matching_subcommand_parsers.first unless matching_subcommand_parsers.empty?
  end
  private :find_subcommand_parser

  def parse_subcommand_arguments(subcommand, args)
    subcommand.parse!(args)
  ensure
    options.deep_merge!(subcommand.options)
  end
  private :parse_subcommand_arguments
end
