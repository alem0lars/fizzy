module Fizzy::Template

  class Context
  end

  class Renderer
    attr_reader :template. :context

    def initialize(template, context)
      @template = template
      @context = context
    end

    def render
      ERB.new(template, 4).result(tainted_context)
    end

    def tainted_context
      context.send(:binding).taint
    end
    private :tainted_context
  end

end
