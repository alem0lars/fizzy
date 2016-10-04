class ErbFromOStruct < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end
