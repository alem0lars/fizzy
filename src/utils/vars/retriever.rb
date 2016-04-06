module Fizzy::Vars
  class Retriever

    include Fizzy::IO

    def initialize(vars)
      @vars = vars
    end

    # Return the variables matching the provided `name`.
    #
    # The result is normally a list of the matching variables; but if `expand`
    # is `true`, empty list is expanded to `nil` and a list of one element is
    # expanded to that element.
    #
    def get(var_name, type: nil, strict: false, single_match: false, expand: true)
      var = _get_var(@vars, var_name, single_match: single_match)
      var = _typize_var(var_name, var, type, strict)

      if expand
        case var.length
        when 0 then nil
        when 1 then var.first
        else var
        end
      else
        var
      end
    end

  protected

    # Accept a list of variables (`vars` argument) and ensure they are correctly
    # typed, according to `type`.
    #
    # If `strict` is `true`, then no type convertion/normalization is done;
    # otherwise, try to guess the correct type.
    #
    def _typize_var(name, var, type, strict)
      Array(var).map do |var|
        if type.nil? || (type.to_s.end_with?("?") && var.nil?)
          var
        else
          case type.to_s.gsub(/\?$/, "").to_sym
          when :string, :str
            strict ? _ensure_type!(name, var, String) : var.to_s
          when :symbol, :sym
            strict ? _ensure_type!(name, var, Symbol) : var.to_s.to_sym
          when :integer, :int
            strict ? _ensure_type!(name, var, Integer) : Integer(var)
          when :boolean, :bool
            if strict
              _ensure_type!(name, var, TrueClass, FalseClass)
            else
              if var.nil?
                nil
              elsif var.is_a?(TrueClass) || var.to_s == "true"
                true
              elsif var.is_a?(FalseClass) || var.to_s == "false"
                false
              else
                error("Invalid value `#{var}` for variable `#{name}`: " +
                      "it can't be converted to a boolean.")
              end
            end
          when :path, :pth then
            if strict && !File.exist?(var)
              error("Invalid variable `#{name}`: `#{var}` doesn't exist")
            else
              Pathname.new(var).expand_path
            end
          when :file, :pth then
            if strict && !File.file?(var)
              error("Invalid variable `#{name}`: `#{var}` isn't a file")
            else
              Pathname.new(var).expand_path
            end
          when :directory, :dir then
            if strict && !File.directory?(var)
              error("Invalid variable `#{name}`: `#{var}` isn't a directory")
            else
              Pathname.new(var).expand_path
            end
          else
            error("Unhandled type `#{type}`. If you need support for a new type, " +
                  "open an issue at `#{Fizzy::CFG.issues_url}`.")
          end
        end
      end
    end

    def _ensure_type!(name, var, *types)
      if types.any?{|type| var.is_a?(type)}
        var
      else
        error("Invalid type for variable `#{name}`: " +
              "it's not a `#{type.name}`.")
      end
    end

    # Returns a list of variables matching the provided `name`, chosen from `vars`.
    #
    # The argument `single_match` can be one of `[:force, true, false]`, to
    # respectively force, restrict to, don't return a single match (the first).
    #
    # This method effectively implements the logic to retrieve variables.
    #
    def _get_var(vars, name, single_match: :force)
      dot_split_regexp = /([^.]+)(?:\.|$)/

      name.to_s.scan(dot_split_regexp).map{|match_group| match_group[0]}
                   .reject(&:empty?)
                   .inject(vars) do |cur_obj, name_component|

        # Intermediate `cur_obj` are lists because every step returns a list.
        # If a step is not-final (i.e. intermediate), we need to be sure there
        # is only one element.
        if cur_obj.is_a?(Array)
          if cur_obj.length == 1
            cur_obj = cur_obj.first
          else
            error("Variabile name diverges: multiple intermediate paths are " +
                  "taken (`[#{cur_obj}]`).")
          end
        end

        # Fill `nxt_obj`.
        nxt_obj = if cur_obj.has_key?(name_component) # Check for exact match.
                    Array[cur_obj[name_component]]
                  else
                    # Check if there are elements with key matching
                    # `name_component` as regexp.
                    # Returns `nil` if nothing is found.
                    cur_obj.select do |k, v|
                      k =~ Regexp.new(/^#{name_component}$/)
                    end.values
                  end

        # Adjust `nxt_obj`, according to `single_match` argument.
        nxt_obj = if single_match
                    if single_match == :force && nxt_obj.length != 1
                      error("Expected a single match for variable `#{name}`, " +
                            "but instead got `#{nxt_obj.length}`")
                    end
                    nxt_obj.first
                  else
                    nxt_obj
                  end

        break nil if nxt_obj.nil? || (nxt_obj.is_a?(Array) && nxt_obj.empty?)
        nxt_obj
      end
    end

  end
end
