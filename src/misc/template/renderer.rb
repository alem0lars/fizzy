class Fizzy::Template::Renderer
  attr_reader :template, :validator

  def initialize(template, validator)
    @template  = template
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
