class Fizzy::LogicParser

  token FEATURE VARIABLE VALUE

  prechigh
    left '&&'
    left '||'
  preclow

rule

  target: exp

  exp: exp '&&' exp            { result &&= val[2]                    }
     | exp '||' exp            { result ||= val[2]                    }
     | '(' exp ')'             { result   = val[1]                    }
     | 'f?' FEATURE            { result   = has_feature?(val[1])      }
     | 'v?' VARIABLE           { result   = !get_var(val[1]).nil?     }
     | 'v?' VARIABLE '=' VALUE { result   = get_var(val[1]) == val[3] }

end

---- inner

  def parse(arg)
    @lexer = Fizzy::LogicLexer.new
    @lexer.start arg
    do_parse
  end


  def next_token
    @lexer.next_token
  end

# vim: set filetype=racc :
