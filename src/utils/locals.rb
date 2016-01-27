module Fizzy::Requirements

  class Proxy

    attr_reader :locals

    def initialize(receiver)
      @receiver = receiver
      @locals   = {}
    end

    # Create a new `local` fetching the value from the corresponding `variable`.
    #
    def variable(name, *args, **kwargs)
      name = name.to_s.to_sym
      error "Invalid local name `#{name}`: it's blank." if name.empty?
      type = options.fetch :type, nil
      local_name = options.fetch :as, name
      if optional
        @locals[local_name] = receiver.get_var name, type: type
      else
        @locals[local_name] = receiver.get_var! name, type: type
      end
    end

    # Create a new computed `local`, based upon other locals.
    #
    def computed(name, fn)
      name = name.to_s.to_sym
      error "Invalid local name `#{name}`: it's blank." if name.empty?
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
      value = local(name)
      error("Undefined local `#{name}`.") if value.nil?
      value
    end

    def local?(*names, &block)
      values = names.collect { |name| local(name) }
      are_locals_available = values.compact.length != values.length
      yield(*values) if are_locals_available
    end

  end

  def define_locals(&block)
    error("No requirements specification provided.") unless block_given?
    proxy = Fizzy::Requirements::Proxy.new self
    proxy.instance_eval(&block)
    self.locals = proxy.locals
  end

end
