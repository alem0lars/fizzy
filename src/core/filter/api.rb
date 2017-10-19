module Fizzy::Filter

  def self.define(name, description: nil, &block)
    @filters ||= []
    @filters << Simple.new(name, description.strip, &block)
  end

  def self.apply(blob)
    if blob.is_a? Hash
      Hash[blob.map { |k, v| [k, apply(v)] }]
    elsif blob.is_a? Array
      blob.map { |v| apply(v) }
    else
      if filter = (@filters || []).find { |f| f.match?(blob) }
        filter.apply(blob)
      else
        blob
      end
    end
  end
end
