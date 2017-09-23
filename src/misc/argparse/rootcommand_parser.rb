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
    @parser             = OptionParser.new
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
    handlers[{ regexp: opt_name, type: :option_name }]   = block
    handlers[{ regexp: opt_value, type: :option_value }] = block if opt_value
  end

  #
  # Run matching handlers if they match sub-command.
  #
  def run
    handlers.each do |info, handler|
      matches = matches_options?(info[:type], info[:regexp])
      break if matches && handler.call(options)
    end
  end

  def parse!(args)
    subcommand_name = pop_subcommand_name!(args)

    subcommand_parser = find_subcommand_parser(subcommand_name)
    if subcommand_parser.nil?
      error(subcommand_name,
            silent: true,
            exc:    Fizzy::ArgParse::InvalidSubCommandName)
    end

    parse_subcommand_arguments(subcommand_parser, args)
  end

  def help(subcommand_name = nil)
    subcommand_name ||= options[:command]
    if subcommand_name
      find_subcommand_parser(subcommand_name).help
    else
      super()
    end
  end

  def tell_help(subcommand_name = nil)
    tell(help(subcommand_name))
  end

  def add_subcommand_parser(subcommand_parser)
    subcommand_parsers << subcommand_parser
  end

  protected

    def banner
      [
        "Usage: #{name} #{options[:command] || "[subcommand]"} [options]",
        "Available sub-commands: #{subcommand_parsers.map(&:name).join(", ")}",
      ].join("\n")
    end

  private

    #
    # Ensures that subcommand name is present in provided `args`.
    #
    # If present, it will be removed from `args` and returned.
    #
    def pop_subcommand_name!(args)
      subcommand_name = args.shift
      if subcommand_name.nil?
        error(nil, silent: true, exc: Fizzy::ArgParse::NoSubCommandName)
      else
        subcommand_name
      end
    end

    #
    # Check if `regexp` (of provided `type`) matches with the current options.
    #
    def matches_options?(type, regexp)
      case type
      when :option_name  then options.any? { |n, _| regexp =~ n }
      when :option_value then options.any? { |_, v| regexp =~ v }
      when :command_name then regexp =~ options[:command]
      end
    end

    def find_subcommand_parser(subcommand_name = nil)
      subcommand_name           ||= options[:command]
      matching_subcommand_parsers =
        subcommand_parsers.select do |c|
          c.name == subcommand_name
        end
      matching_subcommand_parsers.first unless matching_subcommand_parsers.empty?
    end

    def parse_subcommand_arguments(subcommand, args)
      subcommand.parse!(args)
    ensure
      options.deep_merge!(subcommand.options)
    end
end
