class Object

  def must(name,
           value,
           be: nil,
           ge: nil, gt: nil, le: nil, lt: nil)

    if !be.nil?
      # 1: type condition.
      if be.is_a?(Class) && !value.is_a?(be)
        error "Invalid `#{name}` (value=`#{value}`): must be a `#{be}`"
      end

      # 2: not nil condition.
      error "Invalid `#{name}`: must be not nil" if be == :not_nil && value.nil?
    end

    # 3.1: greater-or-equal-than condition.
    if !ge.nil?
      must name, value, be: Number
      must :ge,  ge,    be: Number
      unless value >= ge
        error "Invalid `#{name}`: `#{value}` must be greater or equal than `#{ge}`"
      end
    end

    # 3.2: greater-than condition.
    if !gt.nil?
      must name, value, be: Number
      must :gt,  gt,    be: Number
      unless value > gt
        error "Invalid `#{name}`: `#{value}` must be greater than `#{gt}`"
      end
    end

    # 3.3: lesser-or-equal-than condition.
    if !le.nil?
      must name, value, be: Number
      must :le,  le,    be: Number
      unless value <= le
        error "Invalid `#{name}`: `#{value}` must be lesser or equal than `#{le}`"
      end
    end

    # 3.4: lesser-than condition.
    if !lt.nil?
      must name, value, be: Number
      must :lt,  lt,    be: Number
      unless value < lt
        error "Invalid `#{name}`: `#{value}` must be lesser than `#{lt}`"
      end
    end

    # 3: ad-hoc condition.
    if block_given?
      result = yield(name, value)
      if result.is_a?(Array)
        error "Invalid `#{name}`: #{result[1]}" unless result[0]
      else
        error "Invalid `#{name}`: wrong value `#{value}`" unless result
      end
    end
  end

end
