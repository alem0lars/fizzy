# API:
#
# Fizzy::ArgParse.define_command("foo", "this is bar")
#                .define_command("baz", "this is baz")
#                .parse
#
module Fizzy::ArgParse

  class Parser
    attr_reader :parser, :options

    include Fizzy::IO

    def initialize
      @options = {}
    end

    def parse(args)
      parser.parse!(args)
      options
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
        end
      end

      @subcommand_parsers = []
    end

    def add_subcommand_parser(parser)
      subcommand_parsers << parser
    end

    def parse(args)
      super

      if args.length > 0
        name = args.shift
        matching_parsers = subcommand_parsers.select { |p| p.name == name }

        command_parser = case matching_parsers.length
                         when 0 then error "No command named `#{name}`"
                         when 1 then matching_parsers.first
                         else        error "Multiple commands named `#{name}`"
                         end
        command_parser.parse(args)
        @options = options.deep_merge(command_parser.options)
      end

      options
    end
  end

  class CommandParser < Parser
    attr_reader :name, :desc

    def initialize(name, desc, spec={})
      super()
      @name = name
      @desc = desc
      @parser = OptionParser.new do |opts|
        spec.each do |opt_name, opt_info|
          opt_info = {
            required: false,
            abbrev: nil,
            desc: nil,
            type: nil
          }.merge(opt_info)

          opt_args = []
          opt_args << "-#{opt_info[:abbrev]}" if opt_info[:abbrev]
          if opt_info[:type] == Array
            opt_args << "--#{opt_name} x,y,z"
            opt_args << opt_info[:type]
          elsif opt_info[:type] == :boolean
            opt_args << "--[no-]#{opt_name}"
          else
            if opt_info[:required]
              opt_args << "--#{opt_name} #{opt_name.upcase}"
            else
              opt_args << "--#{opt_name} [#{opt_name.upcase}]"
            end
            opt_args << opt_info[:type] if opt_info[:type]
          end
          opt_args << opt_info[:desc] if opt_info[:desc]

          puts opt_args # TODO remove

          opts.on(*opt_args) do |opt_value|
            @optionsk
          end
        end
      end
      options[:command] = name
    end

    def inspect
      "#{self.class.name}(name=#{name})"
    end
  end

  # ───────────────────────────────────────────────────────────────────── API ──

  def self.define_command(*args, **kwargs)
    Proxy.new.define_command(*args, **kwargs)
  end

  class Proxy
    attr_reader :root_parser, :handlers

    def initialize
      @root_parser = RootParser.new
      @handlers = []
    end

    def define_command(*args, **kwargs)
      root_parser.add_subcommand_parser(*args, **kwargs)
      self
    end

    def on(command_name, block)
      handlers[command_name] = block
    end

    def parse(args)
      root_parser.parse(args)
      handlers.each do |name, fn|
        fn.call(options) if name == options[:command]
      end
    end
  end

  # ────────────────────────────────────────────────────────────────────────────

end
