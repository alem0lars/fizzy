class Fizzy::TypeParser

  token LBRACKET RBRACKET SEP NAME
        LEAF_TYPE
        LIST_TYPE LIST_LBRACKET LIST_RBRACKET
        DICT_TYPE DICT_KEY_SEP DICT_LBRACKET DICT_RBRACKET

rule

  target
    : exp

  exp
    : LEAF_TYPE { puts "ASD -> #{val}"; @eval.add_leaf(val[0]) }

    | LIST_LBRACKET      list_exp LIST_RBRACKET { puts "LIST -> #{val}" }
    | LIST_TYPE LBRACKET list_exp RBRACKET      { puts "LIST -> #{val}" }

    | DICT_LBRACKET      dict_exp DICT_RBRACKET { puts "DICT -> #{val}" }
    | DICT_TYPE LBRACKET dict_exp RBRACKET      { puts "DICT -> #{val}" }

  list_exp
    : list_exp SEP list_exp { puts "LIST_INNER a -> #{val}" }
    | exp                   { puts "LIST_INNER b -> #{val}" }

  dict_exp
    : dict_exp SEP dict_exp { puts "DICT_INNER a -> #{dict}" }
    | NAME DICT_KEY_SEP exp { puts "DICT_INNER b -> #{dict}" }
    | exp                   { puts "DICT_INNER c -> #{dict}" }

end

---- inner

  def parse(untyped_value, type_expression)
    @yydebug = Fizzy::CFG.debug
    @lexer   = Fizzy::TypeLexer.new(type_expression)
    @eval    = Fizzy::TypeEvaluator.new(untyped_value)
    do_parse
    @eval.typed_value
  end

  def next_token
    @lexer.next_token
  end


# vim: set filetype=racc :
