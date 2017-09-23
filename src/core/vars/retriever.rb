module Fizzy::Vars
  class Retriever

    include Fizzy::IO
    include Fizzy::TypeSystem

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
        else        var
        end
      else
        var
      end
    end

    # Accept a list of variables (`vars` argument) and ensure they are correctly
    # typed, according to `type`.
    #
    # See `Fizzy::TypeSystem#typize` for more details.
    #
    def _typize_var(name, variable, type, strict)
      Array(variable).map do |var|
        typize(name, var, type: type, strict: strict)
      end
    end

    protected :_typize_var

    def _ensure_type!(name, var, *types)
      if types.any? { |type| var.is_a?(type) }
        var
      else
        error("Invalid type for variable `#{name}`: " +
              "it's not a `#{type.name}`.")
      end
    end

    protected :_ensure_type!

    # Returns a list of variables matching the provided `name`, chosen from `vars`.
    #
    # The argument `single_match` can be one of `[:force, true, false]`, to
    # respectively force, restrict to, don't return a single match (the first).
    #
    # This method effectively implements the logic to retrieve variables.
    #
    def _get_var(vars, name, single_match: :force)
      dot_split_regexp = /([^.]+)(?:\.|$)/

      var_value = name.to_s
                      .scan(dot_split_regexp)
                      .map { |match_group| match_group[0] }
                      .reject(&:empty?)
                      .inject(vars) do |current_objects, name_component|

        # Intermediate `current_objects` are lists because every step returns
        # a list.
        # If a step is not-final (i.e. intermediate), we need to be sure there
        # is only one element.
        if current_objects.is_a?(Array)
          if current_objects.length == 1
            current_objects = current_objects.first
          else
            error("Variabile name diverges: multiple intermediate paths are " +
                  "taken (`[#{current_objects}]`).")
          end
        end

        # Fill `next_objects`.
        next_objects = if current_objects.has_key?(name_component)
                         # Exact match.
                         Array[current_objects[name_component]]
                       elsif current_objects.has_key?(name_component.to_sym)
                         # Exact match.
                         Array[current_objects[name_component.to_sym]]
                       else
                         # Check if there are elements with key matching
                         # `name_component` as regexp.
                         # Return `nil` if nothing is found.
                         current_objects.select do |k, v|
                           k.to_s =~ Regexp.new(/^#{name_component}$/)
                         end.values
                       end

        # Adjust `next_objects`, according to `single_match` argument.
        next_objects = if single_match
                         if single_match == :force && next_objects.length != 1
                           error("Expected a single match for variable " +
                                 "`#{name}`, but instead got " +
                                 "`#{next_objects.length}`")
                         end
                         next_objects.first
                       else
                         next_objects
                       end

        if next_objects.nil? ||
           (next_objects.is_a?(Array) && next_objects.empty?)
          break nil
        end
        next_objects
      end

      # Filter found variable value.
      Fizzy::Vars::Filters.apply(var_value)
    end

    protected :_get_var

  end
end
