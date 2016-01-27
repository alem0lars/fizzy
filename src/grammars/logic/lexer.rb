class LogicLexer

  require 'strscan'

  def initialize
    @rules = []
  end

  def ignore pattern
    @rules << [pattern, :SKIP]
  end

  def token pattern, token
    @rules << [pattern, token]
  end

  def keyword aString
    @rules << [Regexp.new(aString), aString]
  end

  def start aString
    @base = StringScanner.new aString
  end

  def next_token
    return [false, false] if @base.empty?
    t = get_token
    return (:SKIP == t[0]) ? next_token : t
  end

  def get_token
    @rules.each do |key, value|
      m = @base.scan(key)
      return [value, m] if m
    end
    raise  "unexpected characters  <#{@base.peek(5)}>"
  end

end
