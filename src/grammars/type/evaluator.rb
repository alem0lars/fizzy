class Fizzy::TypeEvaluator

  include Fizzy::IO
  include Fizzy::TypeSystem

  def initialize(untyped_value)
    @untyped_value = untyped_value
    @typed_value = nil
    @stack = []
  end

  def add_list
    @stack.push :list
  end

  def add_leaf(value)
    @stack.push value
  end

  def typed_value
    # byebug

    parse(@untyped_value)
  end

  def parse(value, type: nil)
    case @stack.pop
    when :list
      if value.is_a? Array
        value.map { |e| parse(e ) }
      else
        error "Invalid untyped value `#{value}`: cannot parse into a list"
      end
    else typize(value)
    end
  end

#  private def resolve_type(type)
#    @stack.each do |type|
#      case type
#    end
#  end
end
