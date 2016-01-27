class Hash

  # Perform recursive merge of the current `Hash` (`self`) with the provided one
  # (the `second` argument).
  #
  # The merge have knows how to recurse in both `Hash`es and `Array`s.
  #
  def deep_merge(second)
    merger = proc do |key, v1, v2|
      if Hash === v1 && Hash === v2
        v1.merge v2, &merger
      elsif Array === v1 && Array === v2
        (Set.new(v1) + Set.new(v2)).to_a
      else
        v2
      end
    end
    self.merge second, &merger
  end

  def fqkeys(prefix="")
    self.inject([]) do |acc, (k, v)|
      prefix_new = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
      acc + (v.is_a?(Hash) ? v.fqkeys(prefix_new) : [prefix_new])
    end
  end

end
