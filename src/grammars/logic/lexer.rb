class Fizzy::LogicLexer < Fizzy::BaseLexer

  def initialize
    super

    ignore(/\s+/)

    token(/\w+/, :FEATURE)
    token(/[\w](?:\.[\w]+)*/, :VARIABLE)
    token(/.+/, :VALUE)
  end

end
