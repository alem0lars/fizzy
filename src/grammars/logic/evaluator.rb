class Fizzy::LogicEvaluator

  include Fizzy::IO

  attr_accessor :result

  def initialize(receiver)
    @receiver = receiver
    @result   = nil
  end

  def result=(other)
    @result = result
    debug("Initialized `result` to `#{other}`.")
  end

  def and(other)
    prev_result_value = @result
    @result &&= other
    debug("Performed logical `and` between previous value of result " +
          "(`#{prev_result_value}`) and `#{other}`: operation evaluated " +
          "to `#{@result}`.")
  end

  def or(other)
    prev_result_value = @result
    @result ||= other
    debug("Performed logical `or` between previous value of result " +
          "(`#{prev_result_value}`) and `#{other}`: operation evaluated " +
          "to `#{@result}`.")
  end

  def has_feature?(name)
    @result = @receiver.has_feature?(name)
    debug("Parsed feature `#{name}`: it's #{@result ? "" : "not "}available.")
  end

  def has_variable?(name)
    @result = !@receiver.get_var(name).nil?
    debug("Parsed variable `#{name}` with value " +
          "`#{@receiver.get_var(name)}`: " +
          "it's #{@result ? "" : "not "}available.")
  end

  def variable_value?(name, expected_value)
    @result = @receiver.get_var(name) == expected_value
    debug("Parsed variable `#{name}` with value " +
          "`#{@receiver.get_var(name)}`: " +
          "it's #{@result ? "" : "not "}equal to `#{expected_value}`.")
  end
end
