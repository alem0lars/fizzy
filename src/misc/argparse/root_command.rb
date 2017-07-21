class Fizzy::ArgParse::RootCommand < Fizzy::ArgParse::Command
  attr_reader :subcommands

  def initialize(name, spec: {}, subcommands: [])
    super(name, spec: {
      verbose: { abbrev: "v", desc: "Run verbosely", type: :boolean },
      help: { abbrev: "h", desc: "Prints this help", type: :boolean }
    }.deep_merge(spec))

    @subcommands = subcommands
  end

  def parse!(args)
    parser.banner = [
      "Usage: #{name} #{options[:command] || "[subcommand]"} [options]",
      "Available sub-commands: #{subcommands.map { |c| c.name }.join(", ")}"
    ].join "\n"

    super

    if args.length > 0
      subcommand_name = args.shift

      subcommand = find_subcommand(subcommand_name)
      if subcommand.nil?
        error "No sub-command named `#{subcommand_name}`"
      else
        begin
          subcommand.parse! args
        ensure
          @options = options.deep_merge!(subcommand.options)
        end
      end
    end
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
    if matching_subcommands.length > 0
      matching_subcommands.first
    end
  end
  private :find_subcommand
end

