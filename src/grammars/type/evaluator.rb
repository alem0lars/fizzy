class Fizzy::TypeEvaluator

  include Fizzy::IO
  include Fizzy::TypeSystem

  def initialize(untyped_value)
    @untyped_value = untyped_value
    @typed_value = nil
    @stack = []
  end

  def add_list
    @stack.unshift :list
  end

  def add_leaf(value)
    @stack.unshift value
  end

  def typed_value
    @stack
  end

#  private def resolve_type(type)
#    @stack.each do |type|
#      case type
#    end
#  end
end
