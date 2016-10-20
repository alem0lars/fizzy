module Fizzy::Vars

  include Fizzy::IO

  attr_reader :vars

  # Return a list of the available variables files.
  #
  def avail_vars(vars_dir_path)
    Pathname.glob(vars_dir_path.join("*"))
  end

  # See `Fizzy::Vars::Setup#run`
  #
  def setup_vars(vars_dir_path, name)
    info("vars: ", name)
    @vars = Fizzy::Vars::Setup.new(vars_dir_path, name, binding).run()
  end

  # See `Fizzy::Vars::Retriever#run`
  #
  def var(var_name, **opts)
    Fizzy::Vars::Retriever.new(@vars).get(var_name, **opts)
  end
  alias_method :get_var, :var # NOTE: For backward compatibility

  # Same of `var`, but raise an error if the variable hasn't been found or
  # is `nil`.
  #
  def var!(var_name, **opts)
    value = var(var_name, **opts)
    value.nil? ? error("Undefined variable: `#{var_name}`.") : value
  end
  alias_method :get_var!, :var! # NOTE: For backward compatibility

  # Check if the feature with the provided name (`feature_name`) is enabled.
  #
  # Since the features are defined just using variables, before calling this
  # method be sure that `setup_vars` has already been called.
  #
  def has_feature?(*feature_names)
    features = get_var!("features", single_match: :force)
    feature_names.map(&:to_s).all? do |feature_name|
      features.include? feature_name
    end
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

end
