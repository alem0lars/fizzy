#
# Pure-ruby string diff based on Myers algorithm.
#
class Fizzy::Diff::Generator
  attr_reader :previous, :current

  def initialize(previous, current)
    @previous = previous
    @current  = current
  end

  #
  # Generate diff as a pretty string.
  #
  # @return String The string representation of the computed difference
  #
  def generate_diff_str(tags:   self.class.default_tags,
                        format: -> (*args) { self.class.format_colored(*args) })
    line_width = 4

    output_lines = []

    generate_diff.each do |line|
      tag      = tags[line.type]
      old_line = line.old_line.to_s.rjust(line_width, " ")
      new_line = line.new_line.to_s.rjust(line_width, " ")
      text     = line.text.rstrip

      output_lines << format.call(line.type, tag, old_line, new_line, text)
    end

    output_lines.join("\n")
  end

  #
  # Generate diff in form of: what are the operations needed to transform
  # string `previous` into string `current`.
  #
  # @return Array<Fizzy::Diff::Line> Difference between underlying strings
  #
  def generate_diff
    a, b  = @previous.lines, @current.lines
    trace = compute_exploring_graph(a, b)
    diff  = []

    backtrack(trace, a.size, b.size) do |prev_x, prev_y, x, y|
      if x == prev_x # Forward move
        diff.unshift(Fizzy::Diff::Line.new(:ins, nil, b.size, b.pop))
      elsif y == prev_y # Downward move
        diff.unshift(Fizzy::Diff::Line.new(:del, a.size, nil, a.pop))
      else # Diagonal move
        diff.unshift(Fizzy::Diff::Line.new(:eql, a.size, b.size, [a.pop, b.pop].last))
      end
    end

    diff
  end

  #
  # Create an Exploring Graph as an array, where:
  # - Index is the corresponding depth `d`
  # - Value is an array, where:
  #   - Index is the corresponding `k`
  #   - Value is the corresponding `x` (`y` can be computed doing `y = x - k`)
  #
  # @return Array<Array<Fixnum>> The resulting exploring graph.
  #
  private def compute_exploring_graph(a, b)
    n = a.size
    m = b.size

    # `k` can take values from `-max` to `max`.
    max = n + m

    # Set up an array to store the latest value of `x` for each `k`.
    # First values contain the positives, last the negatives.
    v = Array.new(2 * max + 1)

    # Set `v[1] = 0` so that the iteration for `d = 0` picks `x = 0`.
    #
    # We need to treat the `d = 0` iteration just the same as the later
    # iterations since we might be allowed to move diagonally immediately.
    #
    # Setting `v[1] = 0` makes the algorithm behave as though it begins with a
    # virtual move downwards from `(x, y) = (0,−1)`.
    v[1] = 0 # `k = 1`, `x = 0` => `y = x - k = -1`

    # Store snapshots of `v`.
    trace = []

    (0..max).step do |d|
      trace << v.clone

      (-d..d).step(2) do |k|

        # Get the `x` value of the chosen previous node.
        if k == -d or (k != d and v[k - 1] < v[k + 1])
          x = v[k + 1]
        else
          x = v[k - 1] + 1
        end

        # Compute `y` from `k` and the node's value `x`.
        y = x - k

        # Having taken a single step rightward or downward, we see if we can
        # take any diagonal steps.
        while x < n && y < m && a[x] == b[y]
          x, y = x + 1, y + 1
        end

        v[k] = x

        return trace if x >= n and y >= m
      end
    end
  end

  private def backtrack(trace, x, y)
    trace.each_with_index.reverse_each do |v, d|
      # Calculate the `k` value.
      k = x - y

      # Determine what the previous `k` would have been, using the same logic as
      # in the `compute_exploring_graph` function.
      if k == -d or (k != d and v[k - 1] < v[k + 1])
        prev_k = k + 1
      else
        prev_k = k - 1
      end

      # From that previous `k` value, we can retrieve the previous value of `x`
      # from the trace, and use these `k` and `x` values to calculate the
      # previous `y`.
      prev_x = v[prev_k]
      prev_y = prev_x - prev_k

      # Begin yielding moves back to the caller.
      # If the current x and y values are both greater than the previous ones,
      # we know we can make a diagonal move.
      while x > prev_x and y > prev_y
        yield x - 1, y - 1, x, y
        x, y = x - 1, y - 1
      end

      # Yield a move from the previous x and y from the trace, to the position
      # we reached after following diagonals.
      # This should be a single downward or rightward step.
      yield prev_x, prev_y, x, y if d > 0

      x, y = prev_x, prev_y
    end
  end

  # Maps a line type into a tag.
  def self.default_tags
    { eql: " ", del: "-", ins: "+" }
  end

  # Format the given line diff information into a printable pretty string.
  #
  # In this case the output string contains formatting characters, so it should
  # be feeded into {Fizzy::ANSIColors::colorize} or similar functions.
  def self.format_colored(line_type, tag, old_line, new_line, text)
    default_colors = { eql: "b", del: "r", ins: "g" }
    "{#{default_colors[line_type]}{#{tag} #{old_line} #{new_line}    #{text}}}"
  end

end
