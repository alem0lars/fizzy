class Fizzy::BaseLexer

  include Fizzy::IO

  def initialize(string)
    @base   = StringScanner.new(string)
    @rules  = []
    @tokens = []
  end

  def ignore(pattern)
    @rules << [pattern, [:SKIP]]
  end

  def tokens(patterns, *names)
    Array(patterns).map do |pattern|
      case pattern
      when Regexp then pattern
      when String then Regexp.new(pattern)
      else             Regexp.new(pattern.to_s)
      end
    end.each do |pattern|
      @rules << [pattern, names]
    end
  end

  def token(patterns, name)
    tokens(patterns, name)
  end

  def keyword(name)
    token(Regexp.new(name), name)
  end

  def next_token
    build_tokens if @tokens.empty?
    t = @tokens.shift
    t.first == :SKIP ? next_token : t
  end

private

  # (Re)build the list of tokens.
  # Every token is: `[value, token_name]`.
  def build_tokens
    @tokens  = []
    @tokens += find_tokens until @base.eos?
    @tokens << [false, false] # Last token, meaning EOS.
    debug("Built tokens: `#{@tokens}`.")
  end

  def find_tokens
    @rules.each do |pattern, tokens|
      matched_substring = @base.scan(pattern)
      unless matched_substring.nil?
        if @base[1].nil? # No captures, return the matched string.
          error("Only one token, not `#{tokens.length}` (`#{tokens}`) should " +
                "be provided.") if tokens.length != 1
          return [[tokens.first, matched_substring]]
        else
          captures, base_idx = [], 0
          captures << @base[base_idx] until @base[base_idx += 1].nil?
          error("You need to provide `#{captures.length}` tokens, instead of " +
                "`#{tokens.length}`.") unless captures.length == tokens.length
          return tokens.zip(captures)
        end
      end
    end
    error("Unexpected characters.")
  end

end
