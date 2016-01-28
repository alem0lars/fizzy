require "helper"

class Fizzy::Tests::LogicGrammar < Test::Unit::TestCase
  def test_simple_feature
    vars_mock = Fizzy::Mocks::Vars.new({
      "foo" => "bar",
      "baz" => "qwe",
      features: ["foo"]
    })
    parser = Fizzy::LogicParser.new.parse(vars_mock, "f?foo && v?baz")
    puts "Parser: #{parser}"
  end
end
