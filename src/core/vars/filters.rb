module Fizzy::Vars

  module Filters
    def self.filters
      @filters ||= []
    end

    def self.define(name, description: nil, &block)
      filters << Filter.new(name, description.strip, &block)
    end

    def self.apply(blob)
      if filters.find{|f| f.match?(blob)}
        filter.apply(blob)
      else
        blob
      end
    end

    class Filter

      include Fizzy::IO

      attr_reader :name, :desc

      def initialize(name, desc, &block)
        @name   = name
        @desc   = desc
        @block  = block
        @regexp = /^<\{\s*(?<name>#{@name})\s*(?<args>\S+)\s*\}>$/
      end

      def match?(blob)
        @regexp =~ blob
      end

      def apply(blob)
        md = @regexp.match(blob)
        return if md.nil?
        args = md[:args]
        def args.split_by_separator(sep=",")
          self.split(/(?:\s*[#{sep}]\s*)/)
        end
        @block.call(args)
      end
    end
  end

end
