class Fizzy::TypeLexer < Fizzy::BaseLexer

  def initialize(string)
    super

    ignore(/\s+/)

    token(/</, :LBRACKET)
    token(/>/, :RBRACKET)

    token(/,/, :SEP)

    tokens(%i(
      string str
      symbol sym
      integer int
      boolean bool
      path pth
      directory dir
      file
    ), :LEAF_TYPE)

    token(/\[/, :LIST_LBRACKET)
    token(/\]/, :LIST_RBRACKET)
    tokens(%i(
      array a
      list l
    ), :LIST_TYPE)

    token(/:/, :DICT_KEY_SEP)
    token(/\{/, :DICT_LBRACKET)
    token(/\}/, :DICT_RBRACKET)
    token(%i(
      dictionary dict d
      hash h
    ), :DICT_TYPE)

    # Generic name.
    token(/\S+/, :NAME)
  end

end
