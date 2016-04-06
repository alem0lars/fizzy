module Fizzy::Locals

  extend Forwardable
  include Fizzy::IO

  def_delegators :@locals_proxy, :local, :local!, :local?, :prefix?

  # Entry point for using the DSL defined by `Proxy` class.
  # The DSL is directly accessible inside the provided block.
  #
  def define_locals(&block)
    error("No requirements specification provided.") unless block_given?
    @locals_proxy = Fizzy::Locals::Proxy.new(self)
    @locals_proxy.instance_eval(&block)
  end

  # DSL used for defining locals.
  #
  class Proxy

    include Fizzy::IO
    include Fizzy::TypeSystem

    attr_reader :locals

    def initialize(receiver)
      @receiver = receiver
      @locals   = {}
      @prefix   = nil
      @prefix_history = []
    end

    # ┌────────────────────────────────────────────────────────────────────────┐
    # ├→ DSL definition ───────────────────────────────────────────────────────┤

    # Create a new `local` fetching the value from the corresponding `variable`.
    #
    def variable(name, *args, **opts)
      name = name.to_s.to_sym

      var = _get_var(name, **opts.slice(:type, :strict))

      _set_local(opts.fetch(:as, name),
                 var.nil? ? opts.fetch(:default, nil) : var)
    end

    # Create a new computed `local`, based upon other locals.
    #
    def computed(name, **typize_opts, &block)
      name = name.to_s.to_sym
      error("Invalid local name `#{name}`: it's blank.") if name.empty?
      error("Cannot compute local `#{name}`.") unless block_given?
      value = @receiver.instance_exec(&block)
      value = typize(name, value, **typize_opts) if typize_opts.length > 0
      _set_local(name, value)
    end

    # Access the value of a local.
    #
    def local(name)
      @locals[name.to_s.to_sym]
    end

    # Access the value of a local or raise an error if it's not defined.
    #
    def local!(name)
      value = local(name)
      error("Undefined local `#{name}`.") if value.nil?
      value
    end

    # If all locals identified by `names` are available, evaluate the block
    # passing the locals' values.
    #
    def local?(*names, &block)
      names.collect{|name| local(name)}.compact.length == names.length
    end

    def prefixed(var, as: nil, optional: false)
      error("A block is required") unless block_given?
      unless @receiver.get_var(var.to_s.gsub(/\.$/, ""))
        return if optional
        error("Invalid variable prefix: `#{var}`.")
      end
      @prefix = {var: var, local: as}
      @prefix_history << @prefix
      yield
      @prefix = nil
    end

    # Return `true`, if a prefix starting with the provided `prefix` has
    # been defined; otherwise, `false`.
    #
    def prefix?(prefix)
      @prefix_history.any?{|p| p[:local].to_s.start_with?(prefix.to_s)}
    end

    # └────────────────────────────────────────────────────────────────────────┘

    def _get_var(name, **opts)
      name = @prefix && @prefix[:var] ? "#{@prefix[:var]}#{name}" : name
      @receiver.get_var(name.to_s.to_sym, **opts)
    end

    def _set_local(name, value)
      name = @prefix && @prefix[:local] ? "#{@prefix[:local]}#{name}" : name
      @locals[name.to_s.to_sym] = value
    end

  end

end
