module Fizzy::ArgParse

  class Parser
    attr_reader :parser, :options

    include Fizzy::IO

    def initialize
      @options = {}
    end

    def inspect
      "#{self.class.name}"
    end

    alias_method :to_s, :inspect
  end

  class RootParser < Parser
    attr_reader :subcommand_parsers

    def initialize
      super
      @parser = OptionParser.new do |opts|
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |verbose|
          options[:verbose] = verbose
        end

        opts.on("-h", "--help", "Prints this help") do
          options[:help] = true
          puts opts
        end
      end

      @subcommand_parsers = []
    end

    def add_subcommand_parser(parser)
      subcommand_parsers << parser
    end

    def parse(args)
      args = args.dup
      parser.parse!(args)

      unless options[:help]
        name = args.shift
        matching_parsers = subcommand_parsers.select { |p| p.name == name }

        command_parser = case matching_parsers.length
                         when 0 then error "No command with name `#{name}`"
                         when 1 then matching_parsers.first
                         else        error "Multiple commands matching `#{name}`"
                         end
        command_parser.parse!(args)
        @options = options.deep_merge(command_parser.options)
      end

      options
    end
  end

  class CommandParser < Parser
    attr_reader :name, :desc

    def initialize(name, desc)
      @name = name
      @desc = desc
      @parser = OptionParser.new do |opts|
        opts.on("-h", "--help", "Prints help for command `#{name}`") do
          puts opts
        end
      end
    end

    def inspect
      "#{self.class.name}(name=#{name})"
    end
  end

end
