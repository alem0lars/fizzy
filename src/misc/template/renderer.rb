class Fizzy::Template::Renderer
  attr_reader :data, :validator

  def initialize(data, validator)
    @data  = data
    @validator = validator
  end

  def render(template)
    begin
      validator.validate(data)
    rescue Exception => error
      error "Failed to validate template data #{✏ data}: #{error}"
    end

    ERB.new(template, 1).result(ContextCreator.new.create(data))
  end
end
