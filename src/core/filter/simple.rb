class Fizzy::Filter::Simple < Fizzy::Filter::Base
  def initialize(name, desc, &block)
    super(name, desc)
    @block  = block
    @regexp = /^<\{\s*(?<name>#{@name})\s*(?<args>\S+)\s*\}>$/
  end

  def match?(blob)
    return false unless blob.is_a?(String) || blob.is_a?(Symbol)
    @regexp =~ blob.to_s
  end

  def apply(blob)
    md = @regexp.match(blob)
    return if md.nil?
    args = md[:args]
    def args.split_by_separator(sep = ",")
      split(/(?:\s*[#{sep}]\s*)/)
    end
    debug "Applying filter #{✏ name}"
    @block.call(args)
  end
end
