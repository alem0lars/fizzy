class Fizzy::ArgParse::SubCommand < Fizzy::ArgParse::Command
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
