class Fizzy::Diff
  attr_reader :previous, :current

  def initialize(previous, current)
    @previous = previous
    @current  = current
  end

  def compute_diff
    # TODO
  end
end
