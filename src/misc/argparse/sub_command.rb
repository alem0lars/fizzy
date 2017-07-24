# Sub-command, thus it cannot be parsed standalone but only as part of a
# root-command.
#
class Fizzy::ArgParse::SubCommand < Fizzy::ArgParse::Command
  attr_reader :desc, :spec
  private :spec

  def initialize(name, desc, spec: {})
    super(name)

    @desc = desc.to_s
    @spec = {
      verbose: { abbrev: "v", desc: "Run verbosely", type: :boolean },
      help: { abbrev: "h", desc: "Prints this help", type: :boolean }
    }.deep_merge(spec)

    options[:command] = @name

    @parser = OptionParser.new { |opts| fill_opts(opts) }
  end

  def parse!(args)
    parser.parse!(args)

    missing =
      spec.select { |name, info| info[:required] && options[name].nil? }
          .map { |name, _| name }

    return if missing.empty?
    raise OptionParser::MissingArgument, missing.join(", ")
  end

  def fill_opts(opts)
    spec.each do |opt_name, opt_info|
      opt_info = default_opt_info.merge(opt_info)

      opt_args = compute_opt_args(opt_name, opt_info)

      options[opt_name] = opt_info[:default] if opt_info[:default]

      opts.on(*opt_args) { |opt_value| options[opt_name] = opt_value }
    end
  end
  private :fill_opts

  def compute_opt_args(name, info)
    args = []
    args += compute_abbrev_args(info[:abbrev])
    args += compute_type_args(name, info[:type], info[:required])
    args += compute_desc_args(info[:desc], info[:default])
    args
  end
  private :compute_opt_args

  def compute_abbrev_args(abbrev)
    args = []
    args << "-#{abbrev}" if abbrev
    args
  end
  private :compute_abbrev_args

  def compute_type_args(name, type, req)
    args = []
    if type == Array
      args += ["--#{name} x,y,z", type]
    elsif type == :boolean
      args << "--[no-]#{name}"
    else
      args << (req ? "--#{name} #{name.upcase}" : "--#{name} [#{name.upcase}]")
      args << type if type
    end
    args
  end
  private :compute_type_args

  def compute_desc_args(desc, default)
    args = []
    if desc
      args << (default ? "#{desc} (default: #{default})" : desc)
    elsif default
      args << "Default: #{default}"
    end
    args
  end
  private :compute_desc_args

  def default_opt_info
    {
      required: false,
      abbrev: nil,
      desc: nil,
      type: nil
    }
  end
  private :default_opt_info
end
