class Fizzy::LogicEvaluator

  include Fizzy::IO

  def initialize(receiver)
    @receiver = receiver
    @stack    = []
  end

  def result
    res = @stack.first
    debug("Retrieving result from stack `#{@stack}`: `#{res}`.")
    res
  end

  def and
    arg1   = @stack.pop
    arg2   = @stack.pop
    result = (arg1 == true) && (arg2 == true)
    @stack << result
    debug("Performed logical `and` between `#{arg1}` and `#{arg2}`, " +
          "evaluated to `#{result}`.")
    debug_stack_state
  end

  def or
    arg1   = @stack.pop
    arg2   = @stack.pop
    result = arg1 == true || arg2 == true
    @stack << result
    debug("Performed logical `or` between `#{arg1}` and `#{arg2}`, " +
          "evaluated to `#{result}`.")
    debug_stack_state
  end

  def has_feature?(name)
    result = @receiver.has_feature?(name)
    @stack << result
    debug("Parsed feature `#{name}`: it's #{result ? "" : "not "}available.")
    debug_stack_state
  end

  def has_variable?(name)
    var_value = @receiver.get_var(name)
    result    = !var_value.nil?
    @stack << result
    debug("Parsed variable `#{name}` with value `#{var_value}`: " +
          "it's #{result ? "" : "not "}available.")
    debug_stack_state
  end

  def variable_value?(name, expected_value)
    var_value = @receiver.get_var(name)
    result    = var_value == expected_value
    @stack << result
    debug("Parsed variable `#{name}` with value `#{var_value}`: " +
          "it's #{result ? "" : "not "}equal to `#{expected_value}`.")
    debug_stack_state
  end

  def debug_stack_state
    debug("Stack state is: `#{@stack}`.")
  end

  protected :debug_stack_state

end
