class Fizzy::LogicParser

  token EQ AND OR LBRACKET RBRACKET
        FEATURE_PREFIX FEATURE_NAME
        VAR_PREFIX VAR_NAME
        VALUE

  prechigh
    left AND
    left OR
  preclow

rule

  target
    : exp

  exp
    : LBRACKET exp RBRACKET

    | exp AND exp { @eval.and }
    | exp OR  exp { @eval.or  }

    | FEATURE_PREFIX FEATURE_NAME  { @eval.has_feature?(val[1])            }
    | VAR_PREFIX VAR_NAME          { @eval.has_variable?(val[1])           }
    | VAR_PREFIX VAR_NAME EQ VALUE { @eval.variable_value?(val[1], val[3]) }

end

---- inner

  def parse(receiver, arg)
    @yydebug = Fizzy::CFG.debug
    @lexer   = Fizzy::LogicLexer.new(arg)
    @eval    = Fizzy::LogicEvaluator.new(receiver)
    do_parse
    @eval.result
  end

  def next_token
    @lexer.next_token
  end


# vim: set filetype=racc :
