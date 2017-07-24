# Error representing an invalid subcommand name has been specified.
#
class Fizzy::ArgParse::InvalidSubcommandName < StandardError
  attr_reader :name

  def initialize(name)
    super("Invalid sub-command named #{name}")
    @name = name
  end
end

# Root command, as a composite of sub-commands and some basic global parameters.
#
class Fizzy::ArgParse::RootCommand < Fizzy::ArgParse::Command
  attr_reader :subcommands

  def initialize(name, subcommands: [])
    super(name)

    @subcommands = subcommands
    @parser = OptionParser.new
  end

  # Register a sub-command handler.
  #
  def on(regexp, &block)
    handlers[regexp] = block
  end

  # Run matching handlers if they match sub-command.
  #
  def run
    handlers.each do |regexp, handler|
      handler.call(options) if regexp =~ options[:command]
    end
  end

  def parse!(args)
    parser.banner = banner

    subcommand_name = args.shift
    subcommand = find_subcommand(subcommand_name)
    if subcommand.nil?
      error(subcommand_name,
            silent: true,
            exc: Fizzy::ArgParse::InvalidSubcommandName)
    end

    parse_subcommand_arguments(subcommand, args)
  end

  def tell_help
    if options[:command]
      find_subcommand.tell_help
    else
      super
    end
  end

  def add_subcommand(subcommand)
    subcommands << subcommand
  end

  def find_subcommand(subcommand_name = nil)
    subcommand_name = options[:command] if subcommand_name.nil?
    matching_subcommands = subcommands.select { |c| c.name == subcommand_name }
    matching_subcommands.first unless matching_subcommands.empty?
  end
  private :find_subcommand

  def banner
    [
      "Usage: #{name} #{options[:command] || "[subcommand]"} [options]",
      "Available sub-commands: #{subcommands.map(&:name).join(", ")}"
    ].join "\n"
  end
  private :banner

  def parse_subcommand_arguments(subcommand, args)
    subcommand.parse!(args)
  ensure
    options.deep_merge!(subcommand.options)
  end
  private :parse_subcommand_arguments
end
