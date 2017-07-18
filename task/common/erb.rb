class ErbFromOStruct < OpenStruct

  # Render the provided template using the underlying openstruct object as
  # context.
  #
  def render(template)
    ERB.new(template).result(binding)
  end

end
