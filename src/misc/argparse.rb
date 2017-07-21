# API:
#
# Fizzy::ArgParse.define_command("foo", "this is bar")
#                .define_command("baz", "this is baz")
#                .parse
#
module Fizzy::ArgParse

  class Command
    attr_reader :name, :parser, :options, :handlers, :spec
    protected :spec

    include Fizzy::IO

    def initialize(name, spec: {})
      @name = name.to_s
      @spec = spec
      @parser = OptionParser.new { |opts| fill_opts(opts, spec) }
      @options = {}
      @handlers = []
    end

    def on(command_name, &block)
      handlers << { command_name => block }
    end

    def run
      handlers.each do |name, fn|
        fn.call(options) if name =~ options[:command]
      end
    end

    def parse(args)
      parse!(args)
      true
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      error($!.to_s.titleize, exc: nil)
      tell_help
      false
    end

    def parse!(args)
      parser.parse!(args)
    end

    def tell_help
      tell(parser)
    end

    def inspect
      "#{self.class.name}"
    end

    alias_method :to_s, :inspect

    def fill_opts(opts, opts_spec)
      opts_spec.each do |opt_name, opt_info|
        opt_info = {
          required: false,
          abbrev: nil,
          desc: nil,
          type: nil
        }.merge opt_info

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
          options[opt_name] = opt_value
        end
      end
    end
    private :fill_opts
  end

  class RootCommand < Command
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

  class SubCommand < Command
    attr_reader :desc

    def initialize(name, desc, spec: {})
      super(name, spec: spec)

      @desc = desc.to_s

      options[:command] = @name
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

    def run(args)
      command.parse(args).run
    end
  end

  # ────────────────────────────────────────────────────────────────────────────

end
