class Fizzy::BaseLexer
  include Fizzy::IO

  def initialize
    @rules = []
  end

  def ignore pattern
    @rules << [pattern, :SKIP]
  end

  def token pattern, token
    @rules << [pattern, token]
  end

  def keyword string
    @rules << [Regexp.new(string), string]
  end

  def start string
    @base = StringScanner.new string
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
    error "Unexpected characters  <#{@base.peek(5)}>"
  end

end
