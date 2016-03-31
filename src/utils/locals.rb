module Fizzy::Locals

  include Fizzy::IO

  # Entry point for using the DSL defined by `Proxy` class.
  # The DSL is directly accessible inside the provided block.
  #
  def define_locals(&block)
    error("No requirements specification provided.") unless block_given?
    @locals_proxy = Fizzy::Locals::Proxy.new(self)
    @locals_proxy.instance_eval(&block)
  end

  # ┌──────────────────────────────────────────────────────────────────────────┐
  # ├→ Forward DSL calls to the `Proxy` ───────────────────────────────────────┤

  def local(name)
    @locals_proxy.local(name)
  end

  def local!(name)
    @locals_proxy.local!(name)
  end

  def local?(*names, &block)
    @locals_proxy.local?(*names, &block)
  end

  # └──────────────────────────────────────────────────────────────────────────┘

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
    def variable(name, *args, **opts)
      name = name.to_s.to_sym

      local = @receiver.get_var(name, **opts.slice(:type, :strict))

      @locals[opts.fetch(:as, name).to_sym] = if local.nil?
                                                opts.fetch(:default, nil)
                                              else
                                                local
                                              end
    end

    # Create a new computed `local`, based upon other locals.
    #
    def computed(name, &block)
      name = name.to_s.to_sym
      error("Invalid local name `#{name}`: it's blank.") if name.empty?
      error("Cannot compute local `#{name}`.") unless block_given?

      @locals[name.to_sym] = @receiver.instance_exec(&block)
    end

    # Access the value of a local.
    #
    def local(name)
      @locals[name.to_sym]
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
      values = names.collect{|name| local(name)}
      yield(*values) if values.compact.length == names.length
    end

    # └────────────────────────────────────────────────────────────────────────┘
  end

end
