module Fizzy::Template

  class ContextCreator
    def create(data)
      b = binding
      data.each do |key, value|
        b.local_variable_set(key.taint, value.taint)
      end
      b.taint
    end
  end

  class ContextValidator
    def validate(data)
      true
    end
  end

  class Renderer
    attr_reader :template, :validator

    def initialize(template, validator)
      @template = template
      @validator = validator
    end

    def render(data)
      begin
        validator.validate(data)
      rescue Exception => error
        error "Failed to validate template data #{✏ data}: #{error}"
      end

      ERB.new(template, 1).result(ContextCreator.new.create(data))
    end
  end

end
