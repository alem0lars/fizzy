require "helper"

describe Fizzy::LogicParser do

  before do
    @parser = Fizzy::LogicParser.new

    @vars_mock = Fizzy::Mocks::Vars.new({
      "arte"        => "agility",
      "arti"        => "agility",
      "balpha"      => "strength",
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

  describe "when simple feature" do
    it "should succeed for available features" do
      skip("not working atm")
      @available_features.each { |feature| assert_parse("f?#{feature}") }
    end

    it "should fail for unavailable features" do
      skip("not working atm")
      @unavailable_features.each { |feature| assert_not_parse("f?#{feature}") }
    end
  end

  describe "when simple variable" do
    it "should succeed for available variables" do
      skip("not working atm")
      @available_variables.each { |variable| assert_parse("v?#{variable}") }
    end

    it "should fail for unavailable variables" do
      skip("not working atm")
      @unavailable_variables.each { |variable| assert_not_parse("v?#{variable}") }
    end
  end

  describe "when combined features" do
    it "should succeed for available features" do
      skip("not working atm")
      assert_parse("f?#{@available_features.sample} && f?#{@available_features.sample}")
      assert_parse("f?#{@unavailable_features.sample} || f?#{@available_features.sample}")
    end

    it "should fail for unavailable features" do
      skip("not working atm")
      assert_not_parse("f?#{@unavailable_features.sample} && f?#{@available_features.sample}")
      assert_not_parse("f?#{@unavailable_features.sample} || f?#{@unavailable_features.sample}")
    end
  end

  def assert_parse(expression)
    assert(@parser.parse(@vars_mock, expression),
           "Expression `#{expression}` has been evaluated to `false`.")
  end

  def assert_not_parse(expression)
    assert(!@parser.parse(@vars_mock, expression),
           "Expression `#{expression}` has been evaluated to `true`.")
  end

end
