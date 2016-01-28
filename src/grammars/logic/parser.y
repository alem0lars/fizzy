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

  target: exp

  exp: LBRACKET exp RBRACKET { result = val[1] }

     | exp AND exp { result &&= val[2] }
     | exp OR exp  { result ||= val[2] }

     | FEATURE_PREFIX FEATURE_NAME  { result = @rcv.has_feature?(val[1])      }
     | VAR_PREFIX VAR_NAME          { result = @rcv.!get_var(val[1]).nil?     }
     | VAR_PREFIX VAR_NAME EQ VALUE { result = @rcv.get_var(val[1]) == val[3] }

end

---- inner

  def parse(receiver, arg)
    @rcv = receiver
    @lexer = Fizzy::LogicLexer.new(arg)
    do_parse
  end


  def next_token
    @lexer.next_token
  end

# vim: set filetype=racc :
