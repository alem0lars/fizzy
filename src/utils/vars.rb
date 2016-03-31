module Fizzy::Vars

  include Fizzy::IO
  include Fizzy::Filesystem

  attr_reader :vars

  # Return a list of the available variables files.
  #
  def avail_vars(vars_dir_path)
    Pathname.glob(vars_dir_path.join("*"))
  end

  # Setup the variables that will be used during ERB processing.
  #
  # Those variables will be set into an instance field called `@vars`.
  #
  # After calling this method, you can directly access the variables using
  # `@vars` or using the attribute reader `vars`.
  #
  def setup_vars(vars_dir_path, name)
    info("vars: ", name)
    @vars = _setup_vars(vars_dir_path, name)
  end

  # Check if the feature with the provided name (`feature_name`) is enabled.
  #
  # Since the features are defined just using variables, before calling this
  # method be sure that `setup_vars` has already been called.
  #
  def has_feature?(feature_name)
    get_var!("features", single_match: :force).include?(feature_name.to_s)
  end

  # Filter the values associated to the features, keeping only those
  # associated to available features.
  #
  def data_for_features(info, sep: nil)
    data = []

    info.each do |feature_name, associated_value|
      if has_feature?(feature_name.to_sym)
        if associated_value.respond_to?(:call)
          data << associated_value.call
        else
          data << associated_value
        end
      end
    end

    if data.length == 1
      def data.inspect
        first
      end
    elsif sep
      def data.inspect
        join(sep)
      end
    end

    data
  end

  # Same of `get_var`, but raise an error if the variable hasn't been found or
  # is `nil`.
  #
  def get_var!(var_name, **opts)
    value = get_var(var_name, **opts)
    value.nil? ? error("Undefined variable: `#{var_name}`.") : value
  end

  # Return the variables matching the provided `name`.
  #
  # The variables object being looked up is the one returned from the
  # method `vars`.
  #
  # The result is normally a list of the matching variables; but if `expand`
  # is `true`, empty list is expanded to `nil` and a list of one element is
  # expanded to that element.
  #
  def get_var(var_name, type: nil, strict: false, single_match: false, expand: true)
    var = _get_var(vars, var_name, single_match: single_match)
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
            Pathname.new(var)
          end
        when :file, :pth then
          if strict && !File.file?(var)
            error("Invalid variable `#{name}`: `#{var}` isn't a file")
          else
            Pathname.new(var)
          end
        when :directory, :dir then
          if strict && !File.directory?(var)
            error("Invalid variable `#{name}`: `#{var}` isn't a directory")
          else
            Pathname.new(var)
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

  def _setup_vars(vars_dir_path, name)
    fmt, content = _read_vars(vars_dir_path, name)
    error("Invalid vars: `#{name}`.") if fmt == nil || content == nil
    self_vars    = _parse_vars(fmt, content)
    parents      = _parse_parents_vars(fmt, content)
    parents_vars = _merge_parents_vars(vars_dir_path, parents)
    _merge_with_parents_vars(self_vars, parents_vars)
  end

  def _read_vars(vars_dir_path, name)
    yaml_file_path = find_yaml_path(vars_dir_path.join(name)) unless vars_dir_path.nil? || name.nil?

    if yaml_file_path
      [:yaml, File.read(yaml_file_path)]
    elsif !name.nil? && ENV.has_key?(name)
      [:json, ENV[name]]
    else
      [nil, nil]
    end
  end

  def _parse_vars(fmt, content)
    case fmt
    when :yaml then YAML.load(content) || {}
    when :json
      begin
        JSON.parse(content)
      rescue
        error("Invalid JSON: `#{content}`.")
      end
    else error("Unrecognized format: `#{fmt}`")
    end
  end

  def _parse_parents_vars(fmt, content)
    parents_regexp = case fmt
                     when :yaml then Fizzy::CFG.vars.yaml_regexp
                     when :json then Fizzy::CFG.vars.json_regexp
                     else error("Unrecognized format: `#{fmt}`.")
                     end
    if md = content.match(parents_regexp)
      md[:parents].split(",")
                  .map(&:strip)
                  .reject{|p| p =~ Fizzy::CFG.vars.parent_dummy_regexp}
    else
      []
    end
  end

  def _merge_with_parents_vars(self_vars, parents_vars)
    parents_vars.deep_merge(self_vars)
  end

  def _get_var_collisions(parents_vars)
    collisions = []
    parents_vars.each do |parent_vars|
      others_vars = parents_vars - [parent_vars]
      others_vars.each do |other_vars|
        other_vars_keys = other_vars.fqkeys
        common_keys = other_vars_keys & parent_vars.fqkeys
        common_keys.each do |key|
          value_a = _get_var(parent_vars, key)
          value_b = _get_var(other_vars, key)
          if value_a != value_b
            collisions << { key: key, value_a: value_a, value_b: value_b }
          end
        end
      end
    end
    collisions.uniq do |c| # Remove duplicate collisions.
      [c[:key]] + [c[:value_a], c[:value_b]].sort
    end
  end

  def _merge_parents_vars(vars_dir_path, parents)
    parents.inject([]) do |acc, parent| # Vars for each parent.
      parent_vars = _setup_vars(vars_dir_path, parent)
      acc << parent_vars
      # TODO: Collisions atm compare parents.. this doesn't work well..
      # collisions = _get_var_collisions(acc)
      # unless collisions.empty?
      #   error("Inconsistent variables specification:\n" + collisions.map { |c|
      #           "\t→ Collision with key=`#{c[:key]}`: " +
      #           "value_a=`#{c[:value_a]}` value_b=`#{c[:value_b]}`"
      #         }.join("\n"))
      # end
      acc
    end.inject({}) do |acc, parent_vars| # Merge them.
      acc.deep_merge(parent_vars)
    end
  end

end
