module Fizzy::ArgParse

  class RootParser
    attr_reader :root_parser, :subcommand_parsers

    def initialize
      @root_parser = OptionParser.new do |opts|
        opts.banner = "Usage: opt.rb [options] [subcommand [options]]"
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end
        opts.separator ""
        opts.separator subtext
      end

      @subcommand_parsers = []
    end

    def add_command_parser(*args, **kwargs)
      SubCommandParser.new(*args, **kwargs)
    end

    def parse(args)
      args = args.dup
      options = [root_parser.parse!(args)] + subcommand_parsers.collect do |parser|
        parser.parse!(args)
      end
      puts options
    end
  end

  class SubCommandParser
    attr_reader :parser

    def initialize(name, desc, options)
      @parser = OptionParser.new do
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |verbose|
          options[:verbose] = verbose
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
        end
      end
    end
  end

end
