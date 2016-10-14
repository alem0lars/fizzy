class Object

  def must(name,
           value,
           be: nil,
           ge: nil, gt: nil, le: nil, lt: nil,
           msg: nil)

    def err(msg)
      error msg, exc: ArgumentError
    end

    if !be.nil?
      # 1: type condition.
      if be.is_a?(Class)
        unless value.is_a?(be)
          err "Invalid `#{name}` (value=`#{value}`): must be a `#{be}`"
        end
      end
      if be.is_a?(Array) && be.all? { |b| b.is_a?(Class) }
        unless be.any? { |b| value.is_a?(b) }
          err "Invalid `#{name}` (value=`#{value}`): must be any of `#{be}`"
        end
      end

      # 2: not-`nil` condition.
      err "Invalid `#{name}`: must be not nil" if be == :not_nil && value.nil?
    end

    # 3.1: greater-or-equal-than condition.
    if !ge.nil?
      must name, value, be: Number
      must :ge,  ge,    be: Number
      unless value >= ge
        err "Invalid `#{name}`: `#{value}` must be greater or equal than `#{ge}`"
      end
    end

    # 3.2: greater-than condition.
    if !gt.nil?
      must name, value, be: Number
      must :gt,  gt,    be: Number
      unless value > gt
        err "Invalid `#{name}`: `#{value}` must be greater than `#{gt}`"
      end
    end

    # 3.3: lesser-or-equal-than condition.
    if !le.nil?
      must name, value, be: Number
      must :le,  le,    be: Number
      unless value <= le
        err "Invalid `#{name}`: `#{value}` must be lesser or equal than `#{le}`"
      end
    end

    # 3.4: lesser-than condition.
    if !lt.nil?
      must name, value, be: Number
      must :lt,  lt,    be: Number
      unless value < lt
        err "Invalid `#{name}`: `#{value}` must be lesser than `#{lt}`"
      end
    end

    # 3: ad-hoc condition.
    if block_given?
      result = yield(name, value)
      if result.is_a?(Array)
        err "Invalid `#{name}`: #{result[1]}" unless result[0]
      else
        err "Invalid `#{name}`: wrong value `#{value}`" unless result
      end
    end
  end

end
