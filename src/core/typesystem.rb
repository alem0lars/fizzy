module Fizzy::TypeSystem

  # Check/convert type of the provided `value`,
  # according to the argument `type`.
  #
  # The argument `name` is a logical name to be used for the value,
  # used when logging messages. It can be anything.
  #
  # If `strict` is `true`, then no type convertion/normalization is done;
  # otherwise, try to guess the correct type.
  #
  def typize(name, value, type: nil, strict: false)
    if type.nil? || (type.to_s.end_with?("?") && value.nil?)
      value
    else
      case type.to_s.gsub(/\?$/, "").to_sym
        when :string, :str
          strict ? _ensure_type!(name, value, String) : value.to_s
        when :symbol, :sym
          strict ? _ensure_type!(name, value, Symbol) : value.to_s.to_sym
        when :integer, :int
          strict ? _ensure_type!(name, value, Integer) : Integer(value)
        when :boolean, :bool
          if strict
            _ensure_type!(name, value, TrueClass, FalseClass)
          else
            if value.nil?
              nil
            elsif value.is_a?(TrueClass) || value.to_s == "true"
              true
            elsif value.is_a?(FalseClass) || value.to_s == "false"
              false
            else
              error("Invalid `#{value}` for value `#{name}`: " +
                    "it can't be converted to a boolean.")
            end
          end
        when :path, :pth then
          if strict && !File.exist?(value)
            error("Invalid `#{name}`: `#{value}` doesn't exist")
          else
            Pathname.new(value).expand_path
          end
        when :file then
          if strict && !File.file?(value)
            error("Invalid `#{name}`: `#{value}` isn't a file")
          else
            Pathname.new(value).expand_path
          end
        when :directory, :dir then
          if strict && !File.directory?(value)
            error("Invalid `#{name}`: `#{value}` isn't a directory")
          else
            Pathname.new(value).expand_path
          end
        else
          error("Unhandled type `#{type}`. If you need support for a new " +
                "type, open an issue at `#{Fizzy::CFG.issues_url}`.")
      end
    end
  end

end
