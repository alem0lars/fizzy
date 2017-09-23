module Fizzy::Vars
  module Filter
    def self.define(name, description: nil, &block)
      @filters ||= []
      @filters << SimpleFilter.new(name, description.strip, &block)
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

    class SimpleFilter
      include Fizzy::IO

      attr_reader :name, :desc

      def initialize(name, desc, &block)
        @name   = name
        @desc   = desc
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
        @block.call(args)
      end
    end
  end
end
