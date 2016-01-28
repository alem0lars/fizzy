class Fizzy::LogicLexer < Fizzy::BaseLexer

  def initialize(string)
    super

    ignore(/\s+/)

    token(/=/,    :EQ)
    token(/&&/,   :AND)
    token(/\|\|/, :OR)
    token(/\(/,   :LBRACKET)
    token(/\)/,   :RBRACKET)

    tokens(/(f\?)(\w+)/, :FEATURE_PREFIX, :FEATURE_NAME)

    tokens(/(v\?)([\w](?:[._-][\w]+)*)/, :VAR_PREFIX, :VAR_NAME)

    token(/.+/, :VALUE) # Anything that would otherwise not match is a value.
  end

end
