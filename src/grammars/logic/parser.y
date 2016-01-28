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

  exp: LBRACKET exp RBRACKET { @res = val[1] }

     | exp AND exp { @res &&= val[2] }
     | exp OR exp  { @res ||= val[2] }

     | FEATURE_PREFIX FEATURE_NAME  { check_feature_avail(val[1])     }
     | VAR_PREFIX VAR_NAME          { check_var_avail(val[1])         }
     | VAR_PREFIX VAR_NAME EQ VALUE { check_var_value(val[1], val[3]) }

end

---- header

  include Fizzy::IO

---- inner

  def parse(receiver, arg)
    @yydebug = Fizzy::CFG.debug
    @rcv = receiver
    @lexer = Fizzy::LogicLexer.new(arg)
    do_parse
    @res
  end

  def next_token
    @lexer.next_token
  end

private

  def check_feature_avail(name)
    @res = @rcv.has_feature?(name)
    debug("Parsed feature `#{name}`: it's #{@res ? "" : "not "}available.")
  end

  def check_var_avail(name)
    @res = !@rcv.get_var(name).nil?
    debug("Parsed variable `#{name}` with value `#{@rcv.get_var(name)}`: " +
          "it's #{@res ? "" : "not "}available.")
  end

  def check_var_value(name, expected_value)
    @res = @rcv.get_var(name) == expected_value
    debug("Parsed variable `#{name}` with value `#{@rcv.get_var(name)}`: " +
          "it's #{@res ? "" : "not "}equal to `#{expected_value}`.")
  end

# vim: set filetype=racc :
