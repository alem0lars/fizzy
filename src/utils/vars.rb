module Fizzy::Vars

  attr_reader :vars

  def _get_var(vars, var_name)
    dot_split_regexp = /([^.]+)(?:\.|$)/
    var_name.to_s
      .scan(dot_split_regexp).map { |match_group| match_group[0] }
      .reject(&:empty?)
      .inject(vars) do |cur_obj, name_component|

      nxt_obj = if cur_obj.has_key?(name_component)
        cur_obj[name_component]
      else
        nil
      end
      nxt_obj or break nil
    end
  end

  def _read_vars(vars_dir_path, name)
    yaml_file_path = find_yaml_path(File.join(vars_dir_path, name))
    if yaml_file_path
      [:yaml, File.read(yaml_file_path)]
    elsif ENV.has_key? name
      [:json, ENV[name]]
    else
      [nil, nil]
    end
  end

  def _parse_parents_vars(fmt, content)
    dummy_regex = /none|nothing/i
    parents_regex = case fmt
    when :yaml then /^#\s*=>\s*inherits\s*(:\s+)?(?<parents>.+)\s*<=\s*#\s*/
    when :json then /^\/\*\s*=>\s*inherits\s*(:\s+)?(?<parents>.+)\s*<=\s*\*\/\s*/
    else error("Unrecognized format: `#{fmt}`")
    end
    if md = content.match(parents_regex)
      md[:parents].split(",").map(&:strip).reject { |p| p =~ dummy_regex }
    else
      []
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

  def _merge_with_parents_vars(self_vars, parents_vars)
    parents_vars.deep_merge(self_vars)
  end

  def _get_vars_collisions(parents_vars)
    collisions = []
    parents_vars.each do |parent_vars|
      parent_vars_keys = parent_vars.fqkeys
      others_vars = parents_vars - [parent_vars]
      others_vars.each do |other_vars|
        other_vars_keys = other_vars.fqkeys
        common_keys = other_vars_keys & parent_vars_keys
        common_keys.each do |key|
          value_a = _get_var(parent_vars, key)
          value_b = _get_var(other_vars, key)
          if value_a != value_b
            collisions << { key: key, value_a: value_a, value_b: value_b }
          end
        end
      end
    end
    collisions.uniq do |c| # remove duplicate collisions
      [c[:key]] + [c[:value_a], c[:value_b]].sort
    end
  end

  def _merge_parents_vars(vars_dir_path, parents)
    parents.inject([]) do |acc, parent| # vars for each parent
      parent_vars = _setup_vars(vars_dir_path, parent)
      acc << parent_vars
      collisions = _get_vars_collisions(acc)
      unless collisions.empty?
        error "Inconsistent variables specification:\n" + collisions.map { |c|
          "\t→ Collision with key=`#{c[:key]}`: value_a=`#{c[:value_a]}` value_b=`#{c[:value_b]}`"
        }.join("\n")
      end
      acc
    end.inject({}) do |acc, parent_vars| # merge them
      acc.deep_merge(parent_vars)
    end
  end

  def _setup_vars(vars_dir_path, name)
    fmt, content = _read_vars(vars_dir_path, name)
    error("Invalid vars: `#{name}`.") if fmt == nil || content == nil
    self_vars = _parse_vars(fmt, content)
    parents = _parse_parents_vars(fmt, content)
    parents_vars = _merge_parents_vars(vars_dir_path, parents)
    _merge_with_parents_vars(self_vars, parents_vars)
  end

  #
  # Setup the variables that will be used during ERB processing.
  #
  # Those variables will be set into an instance field called `@vars`.
  #
  # After calling this method, you can directly access the variables using
  # `@vars` or using the attribute reader `vars`.
  #
  def setup_vars(vars_dir_path, name)
    info "vars: ", name
    @vars = _setup_vars(vars_dir_path, name)
  end

  #
  # Return the variable matching the provided `name`.
  #
  # The variables object being looked up is the one returned from the
  # method `vars`.
  #
  def get_var(var_name)
    _get_var(vars, var_name)
  end

  #
  # Same of `get_var`, but raise an error if the variable hasn't been found or
  # is `nil`.
  #
  def get_var!(var_name)
    get_var(var_name) || error("Undefined or `nil` variable: `#{var_name}`.")
  end

  #
  # Check if the feature with the provided name (`feature_name`) is enabled.
  #
  # Since the features are defined just using variables, before calling this
  # method be sure that `setup_vars` has already been called.
  #
  def has_feature?(feature_name)
    get_var!('features').include? feature_name.to_s
  end

  #
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
      def data.inspect() first end
    elsif sep
      def data.inspect() join(sep) end
    end
    data
  end

end
