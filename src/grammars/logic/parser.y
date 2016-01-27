class LogicParser

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

  def make_lexer aString
    result = LogicLexer.new
    result.ignore /\s+/
    result.keyword 'item'
    result.token /\w+/, :WORD
    result.start aString
    return result
  end


  def parse(arg)
    @result = Catalog.new
    @lexer = make_lexer arg
    do_parse
  end

# vim: set filetype=racc :
