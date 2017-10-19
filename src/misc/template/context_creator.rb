class Fizzy::Template::Context::Creator

  #
  # Create a new context based on the provided data.
  #
  def create(data)
    b = binding
    data.each do |key, value|
      b.local_variable_set(key.taint, value.taint)
    end
    b.taint
  end

end
