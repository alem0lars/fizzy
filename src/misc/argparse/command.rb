class Fizzy::ArgParse::Command
  attr_reader :name, :parser, :options, :handlers, :spec
  protected :spec

  include Fizzy::IO

  def initialize(name, spec: {})
    @name = name.to_s
    @spec = spec
    @parser = OptionParser.new { |opts| fill_opts(opts, spec) }
    @options = {}
    @handlers = {}
  end

  def on(regexp, &block)
    handlers[regexp] = block
  end

  def run
    handlers.each do |regexp, handler|
      handler.call(options) if regexp =~ options[:command]
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
