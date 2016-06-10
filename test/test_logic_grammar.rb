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

    @avail_features = %w(accu amun-ra corr_disc the-eme_ward)
    @unavail_features = %w(arti amun_ra corr-disc the-eme-ward empath)
    @avail_vars = %w(arte doc-rep flint_beast keep-of_the.lake)
    @unavail_vars = %w(accu doc_rep flint-beast keep_of_the.lake ophe)
  end

  def avail_var
    "v?#{@avail_vars.sample}"
  end

  def avail_feature
    "f?#{@avail_features.sample}"
  end

  def unavail_var
    "v?#{@unavail_vars.sample}"
  end

  def unavail_feature
    "f?#{@unavail_features.sample}"
  end

  describe "when simple feature" do
    it "should succeed for available features" do
      @avail_features.each { |feature| assert_parse("f?#{feature}") }
    end

    it "should fail for unavailable features" do
      @unavail_features.each { |feature| assert_not_parse("f?#{feature}") }
    end
  end

  describe "when simple variable" do
    it "should succeed for available variables" do
      @avail_vars.each { |variable| assert_parse("v?#{variable}") }
    end

    it "should fail for unavailable variables" do
      @unavail_vars.each { |variable| assert_not_parse("v?#{variable}") }
    end
  end

  describe "when combined features" do
    it "should succeed for available features" do
      assert_parse("#{avail_feature} && #{avail_feature}")
      assert_parse("#{unavail_feature} || #{avail_feature}")
    end

    it "should fail for unavailable features" do
      assert_not_parse("#{unavail_feature} && #{avail_feature}")
      assert_not_parse("#{unavail_feature} || #{unavail_feature}")
    end
  end

  describe "when conditions are nested" do
    it "should succeed" do
      # Only variables.
      assert_parse("#{avail_var} && (#{avail_var} || #{unavail_var})")
      assert_parse("(#{avail_var} && #{avail_var}) && (#{avail_var} || #{unavail_var})")
      # Only features.
      assert_parse("#{avail_feature} && (#{avail_feature} || #{unavail_feature})")
      assert_parse("(#{avail_feature} && #{avail_feature}) && (#{avail_feature} || #{unavail_feature})")
      # Both.
      assert_parse("(#{avail_var} && #{avail_feature}) && (#{unavail_feature} || (#{avail_var} || #{unavail_feature}))")
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
