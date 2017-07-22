class Fizzy::LogicLexer < Fizzy::BaseLexer

  def initialize(string)
    super

    ignore(/\s+/)

    token(/=/,    :EQ)
    token(/&&/,   :AND)
    token(/\|\|/, :OR)
    token(/\(/,   :LBRACKET)
    token(/\)/,   :RBRACKET)

    tokens(/(f\?)(#{name_with("-_")})/,  :FEATURE_PREFIX, :FEATURE_NAME)
    tokens(/(v\?)(#{name_with("-_.")})/, :VAR_PREFIX,     :VAR_NAME)

    token(/.+/, :VALUE) # Anything that would otherwise not match is a value.
  end

private

  def name_with(symbols)
    /\w+(?:[#{symbols}]\w+)*/
  end

end
