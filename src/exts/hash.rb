class Hash

  # Extract `n` sample key/value pairs from the underlying `Hash`.
  def sample(n=1)
    Hash[self.to_a.sample(n)]
  end

  # Define magic merge strategy:
  #
  # 1. Merge hashes
  # 2. Concatenate arrays
  #
  def magic_merge_strategy
    proc do |key, v1, v2|
      if Hash === v1 && Hash === v2
        v1.merge(v2, &magic_merge_strategy)
      elsif Array === v1 && Array === v2
        (SortedSet.new(v1) + SortedSet.new(v2)).to_a
      else
        v2
      end
    end
  end
  private :magic_merge_strategy

  # Perform recursive merge with some magic, replacing current hash.
  #
  def magic_merge!(second)
    self.merge!(second, &magic_merge_strategy)
  end

  # Perform recursive merge with some magic, creating a new hash.
  #
  def magic_merge(second)
    self.merge(second, &magic_merge_strategy)
  end

  # Define merge strategy.
  #
  # 1. Merge hashes
  #
  def deep_merge_strategy
    proc do |key, v1, v2|
      if Hash === v1 && Hash === v2
        v1.merge(v2, &deep_merge_strategy)
      else
        v2
      end
    end
  end
  private :deep_merge_strategy

  # Perform recursive merge, replacing current hash.
  #
  def deep_merge!(second)
    self.merge!(second, &deep_merge_strategy)
  end

  # Perform recursive merge, creating a new hash.
  #
  def deep_merge(second)
    self.merge(second, &deep_merge_strategy)
  end

  def fqkeys(prefix="")
    self.inject([]) do |acc, (k, v)|
      prefix_new = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
      acc + (v.is_a?(Hash) ? v.fqkeys(prefix_new) : [prefix_new])
    end
  end

  def slice(*keys)
    self.select{|k, _| keys.include?(k)}
  end

  # ────────────────────────────────────────────────────────────────────────────
  # ☞ Convert keys

  # Return a new `Hash` with all keys converted to `String`s.
  #
  def deep_stringify_keys
    deep_transform_keys{ |key| key.to_s }
  end

  # Destructively convert all keys to `String`s.
  #
  def deep_stringify_keys!
    deep_transform_keys!{ |key| key.to_s }
  end

  # Return a new `Hash` with all keys converted to `Symbol`s, as long as they
  # respond to `to_sym`.
  #
  def deep_symbolize_keys
    deep_transform_keys{ |key| key.to_sym rescue key }
  end

  # Destructively convert all keys to `Symbol`s, as long as they respond to
  # `to_sym`.
  #
  def deep_symbolize_keys!
    deep_transform_keys!{ |key| key.to_sym rescue key }
  end

  # Return a new `Hash` with all keys converted by the block operation.
  #
  def deep_transform_keys(&block)
    deep_transform_keys_in_object(self, &block)
  end

  # Destructively convert all keys by using the block operation.
  #
  def deep_transform_keys!(&block)
    deep_transform_keys_in_object!(self, &block)
  end

  def deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = deep_transform_keys_in_object(value, &block)
      end
    when Array
      object.map {|e| deep_transform_keys_in_object(e, &block)}
    else object
    end
  end
  private :deep_transform_keys_in_object

  def deep_transform_keys_in_object!(object, &block)
    case object
    when Hash
      object.keys.each do |key|
        value = object.delete(key)
        object[yield(key)] = deep_transform_keys_in_object!(value, &block)
      end
      object
    when Array
      object.map! {|e| deep_transform_keys_in_object!(e, &block)}
    else object
    end
  end
  private :deep_transform_keys_in_object!

  # ────────────────────────────────────────────────────────────────────────────

end
