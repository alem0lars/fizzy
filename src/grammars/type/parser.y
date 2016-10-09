class Fizzy::TypeParser

  token LBRACKET RBRACKET
        LIST_TYPE LIST_LBRACKET LIST_RBRACKET
        LEAF_TYPE

rule

  target: exp

  exp: LBRACKET exp RBRACKET

     | LIST_LBRACKET exp LIST_RBRACKET { puts "QWE -> #{val}"; @eval.add_list }
     | LIST_TYPE LBRACKET exp RBRACKET { puts "RTY -> #{val}"; @eval.add_list }
     | LEAF_TYPE { puts "ASD -> #{val}"; @eval.add_leaf(val[0]) }

end

---- inner

  def parse(untyped_value, type_expression)
    @yydebug = Fizzy::CFG.debug
    @lexer   = Fizzy::TypeLexer.new(type_expression)
    @eval    = Fizzy::TypeEvaluator.new(untyped_value)
    do_parse
    byebug
    @eval.typed_value
  end

  def next_token
    @lexer.next_token
  end


# vim: set filetype=racc :
