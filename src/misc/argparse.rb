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
      parse!(args)
      true
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      tell($!.to_s)
      tell_help
      false
    end

    def parse!(args)
      parser.parse!(args)
    end

    def tell_help
      tell(parser.to_s)
    end

    def inspect
      "#{self.class.name}"
    end

    alias_method :to_s, :inspect
  end

  class Command < Parser
    attr_reader :subcommands

    def initialize
      super
      @parser = OptionParser.new do |opts|
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |verbose|
          options[:verbose] = verbose
        end

        opts.on("-h", "--help", "Prints this help") do |help|
          options[:help] = help
        end
      end

      @subcommands = []
    end

    def parse!(args)
      super

      if args.length > 0
        name = args.shift

        subcommand = find_subcommand(name)
        if subcommand.nil?
          error "No command named `#{name}`"
        else
          subcommand.parse!(args)
          @options = options.deep_merge(subcommand.options)
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

    def find_subcommand(name=nil)
      name = options[:command] if name.nil?
      matching_subcommands = subcommands.select { |p| p.name == name }
      if matching_subcommands.length > 0
        matching_subcommands.first
      end
    end
    private :find_subcommand
  end

  class SubCommand < Parser
    attr_reader :name, :desc, :spec

    def initialize(name, desc, spec={})
      super()

      # 1: Initialize `@name`, `@desc`, `@spec`
      @name = name
      @desc = desc
      @spec = spec

      options[:command] = name

      # 2: Initialize `@parser`
      @parser = OptionParser.new do |opts|
        @spec.each do |opt_name, opt_info|
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

          opts.on(*opt_args) do |opt_value|
            @options[opt_name] = opt_value
          end
        end
      end
    end

    def parse!(args)
      super

      missing = spec.select do |name, info|
        info[:required] && options[name].nil?
      end.map { |name, _| name }

      unless missing.empty?
        raise OptionParser::MissingArgument.new(missing.join(", "))
      end
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
    attr_reader :command, :handlers

    def initialize
      @command = Command.new
      @handlers = []
    end

    def define_command(*args, **kwargs)
      command.add_subcommand(*args, **kwargs)
      self
    end

    def on(command_name, block)
      handlers[command_name] = block
    end

    def parse(args)
      command.parse(args)
      handlers.each do |name, fn|
        fn.call(options) if name == options[:command]
      end
    end
  end

  # ────────────────────────────────────────────────────────────────────────────

end
