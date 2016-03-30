module Fizzy::Locals

  include Fizzy::IO

  # Entry point for using the DSL defined by `Proxy` class.
  # The DSL is directly accessible inside the provided block.
  #
  def define_locals(&block)
    error("No requirements specification provided.") unless block_given?
    proxy = Fizzy::Locals::Proxy.new(self)
    proxy.instance_eval(&block)
    self.locals = proxy.locals
  end

  # DSL used for defining locals.
  #
  class Proxy

    include Fizzy::IO

    attr_reader :locals

    def initialize(receiver)
      @receiver = receiver
      @locals   = {}
    end

    # ┌────────────────────────────────────────────────────────────────────────┐
    # ├→ DSL definition ───────────────────────────────────────────────────────┤

    # Create a new `local` fetching the value from the corresponding `variable`.
    #
    def variable(name, *args, **options)
      name = name.to_s.to_sym

      # Read provided options.
      type       = options.fetch(:type,    nil)
      local_name = options.fetch(:as,      name)
      default    = options.fetch(:default, nil)

      local = receiver.get_var(name, type: type)
      @locals[local_name] = local.nil? ? local : default
    end

    # Create a new computed `local`, based upon other locals.
    #
    def computed(name, fn)
      name = name.to_s.to_sym
      error("Invalid local name `#{name}`: it's blank.") if name.empty?
      error("Cannot compute local `#{name}`.") if fn.nil?

      @locals[name] = fn.call
    end

    # Access the value of a local.
    #
    def local(name)
      locals[name]
    end

    # Access the value of a local or raise an error if it's not defined.
    #
    def local!(name)
      value = local name
      error("Undefined local `#{name}`.") if value.nil?
      value
    end

    # If all locals identified by `names` are available, evaluate the block
    # passing the locals' values.
    #
    def local?(*names, &block)
      values = names.collect{|name| local(name)}
      are_locals_available = values.compact.length != values.length
      yield(*values) if are_locals_available
    end

    # └────────────────────────────────────────────────────────────────────────┘

  end

end
