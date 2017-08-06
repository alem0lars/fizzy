#
# Sub-command, thus it cannot be parsed standalone but only as part of a
# root-command.
#
class Fizzy::ArgParse::SubCommandParser < Fizzy::ArgParse::CommandParser
  attr_reader :desc, :spec
  private :spec

  def initialize(name, desc, spec: {})
    super(name)

    @desc = desc.to_s
    @spec = {
      verbose: { abbrev: "v", desc: "Run verbosely", type: :boolean }
    }.deep_merge(spec)

    options[:command] = @name

    @parser = OptionParser.new { |opts| fill_opts(opts) }
  end

  def parse!(args)
    parser.banner = banner
    parser.parse!(args)

    missing =
      spec.select { |name, info|  info[:required] && options[name].nil? }
          .map    { |name, _info| name }

    return if missing.empty?
    raise OptionParser::MissingArgument, missing.join(", ")
  end

  def help_to_s
    puts "help_to_s"
  end

  protected

  def banner
    # TODO, replace "fizzy" with rootcommand name (find a way to find
    #       rootcommand from subcommand)
    [
      "Usage: fizzy #{name} [options]",
      desc
    ].join("\n")
  end

  private

  def fill_opts(opts)
    spec.each do |opt_name, opt_info|
      opt_info = default_opt_info.merge(opt_info)

      opt_args = compute_opt_args(opt_name, opt_info)

      options[opt_name] = opt_info[:default] if opt_info[:default]

      opts.on(*opt_args) { |opt_value| options[opt_name] = opt_value }
    end
  end

  def compute_opt_args(name, info)
    args = []
    args += compute_abbrev_args(info[:abbrev])
    args += compute_type_args(name, info[:type], info[:required])
    args += compute_desc_args(info[:desc], info[:default], info[:type])
    args
  end

  def compute_abbrev_args(abbrev)
    args = []
    args << "-#{abbrev}" if abbrev
    args
  end

  def compute_type_args(name, type, req)
    arg_name = name.to_s.dasherize
    args = []
    if type == Array
      args += ["--#{arg_name} x,y,z", type]
    elsif type == :boolean
      args << "--[no-]#{arg_name}"
    else
      args << if req
                "--#{arg_name} #{name.upcase}"
              else
                "--#{arg_name} [#{name.upcase}]"
              end
      args << type if type
    end
    args
  end

  def compute_desc_args(desc, default, type)
    full_desc = desc
    full_desc << " (default: #{default})" if default
    full_desc << " (allowed: #{type.join(", ")})" if type.is_a? Array
    [full_desc]
  end

  def default_opt_info
    {
      required: false,
      abbrev: nil,
      desc: nil,
      type: nil
    }
  end
end
