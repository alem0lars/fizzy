class Fizzy::LogicEvaluator

  include Fizzy::IO

  def initialize(receiver)
    @receiver        = receiver
    @partial_results = []
    @result          = nil
  end

  def result
    # In case no operations that transform the partial results
    # (`@partial_results`) into the final result (`@result`) have been used
    # (e.g. operations `and`, `or`); return the accumulated partial result.
    if @result.nil? && @partial_results.length == 1
      @result = @partial_results.first
    end
    # Return the evaluation's result.
    @result
  end

  def result=(initial_result)
    @result = initial_result
    debug("Initialized `result` to `#{initial_result}`.")
  end

  def and
    @result = @partial_results.all? { |e| e == true }
    debug("Performed logical `and` between the stored partial results " +
          "`#{@partial_results}`: evaluating to `#{@result}`.")
  end

  def or
    @result = @partial_results.any? { |e| e == true }
    debug("Performed logical `or` between the stored partial results " +
          "`#{@partial_results}`: evaluating to `#{@result}`.")
  end

  def has_feature?(name)
    @partial_results << @receiver.has_feature?(name)
    debug("Parsed feature `#{name}`: it's #{@result ? "" : "not "}available.")
  end

  def has_variable?(name)
    @partial_results << !@receiver.get_var(name).nil?
    debug("Parsed variable `#{name}` with value " +
          "`#{@receiver.get_var(name)}`: " +
          "it's #{@result ? "" : "not "}available.")
  end

  def variable_value?(name, expected_value)
    @partial_results << (@receiver.get_var(name) == expected_value)
    debug("Parsed variable `#{name}` with value " +
          "`#{@receiver.get_var(name)}`: " +
          "it's #{@result ? "" : "not "}equal to `#{expected_value}`.")
  end
end
