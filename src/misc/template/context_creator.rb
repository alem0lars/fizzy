class Fizzy::Template::Context::Creator
  def create(data)
    b = binding
    data.each do |key, value|
      b.local_variable_set(key.taint, value.taint)
    end
    b.taint
  end
end
