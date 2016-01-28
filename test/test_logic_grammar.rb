require "helper"

class Fizzy::Tests::LogicGrammar < Test::Unit::TestCase

  def test_simple_feature_success
    @available_features.each { |feature| assert_parse("f?#{feature}") }
  end

  def test_simple_feature_failure
    @unavailable_features.each { |feature| assert_not_parse("f?#{feature}") }
  end

  def test_simple_variable_success
    @available_variables.each { |variable| assert_parse("v?#{variable}") }
  end

  def test_simple_variable_failure
    @unavailable_variables.each { |variable| assert_not_parse("v?#{variable}") }
  end

  def setup
    @parser = Fizzy::LogicParser.new

    @vars_mock = Fizzy::Mocks::Vars.new({
      "arte"        => "agility",
      "arti"   => "agility",
      "balpha"  => "strength",
      "doc-rep"     => "intelligence",
      "flint_beast" => "agility",
      "keep-of_the" => {
        "lake"   => "strength",
        "street" => "strength"
      },
      features: %w(accu aluna andro amun-ra corr_disc the-eme_ward)
    })

    @available_features = %w(accu amun-ra corr_disc the-eme_ward)
    @unavailable_features = %w(arti amun_ra corr-disc the-eme-ward empath)
    @available_variables = %w(arte doc-rep flint_beast keep-of_the.lake)
    @unavailable_variables = %w(accu doc_rep flint-beast keep_of_the.lake ophe)
  end

private

  def assert_parse(expression)
    assert(@parser.parse(@vars_mock, expression),
           "Expression `#{expression}` has been evaluated to `false`.")
  end

  def assert_not_parse(expression)
    assert(!@parser.parse(@vars_mock, expression),
           "Expression `#{expression}` has been evaluated to `true`.")
  end

end
