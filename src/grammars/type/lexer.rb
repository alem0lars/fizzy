class Fizzy::TypeLexer < Fizzy::BaseLexer

  def initialize(string)
    super

    leaf_types = %i(
      string str
      symbol sym
      integer int
      boolean bool
      path pth
      directory dir
      file
    )

    list_types = %i(
      array a
      list l
    )
    #dict_types = %i(
    #  dictionary dict hash
    #)

    ignore(/\s+/)

    token(/</, :LBRACKET)
    token(/>/, :RBRACKET)

    token(/\[/, :LIST_LBRACKET)
    token(/\]/, :LIST_RBRACKET)
    tokens(list_types, :LIST_TYPE)

    tokens(leaf_types, :LEAF_TYPE)
  end

end
