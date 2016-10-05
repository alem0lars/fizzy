require "spec_helper"


describe Fizzy::LogicParser do

  let(:avail_features)   { %w(accu amun-ra corr_disc the-eme_ward) }
  let(:unavail_features) { %w(arti amun_ra corr-disc the-eme-ward empath) }
  let(:avail_vars)       { %w(arte doc-rep flint_beast keep-of_the.lake) }
  let(:unavail_vars)     { %w(accu doc_rep flint-beast keep_of_the.lake ophe) }

  let(:avail_var)       { "v?#{avail_vars.sample}" }
  let(:avail_feature)   { "f?#{avail_features.sample}" }
  let(:unavail_var)     { "v?#{unavail_vars.sample}" }
  let(:unavail_feature) { "f?#{unavail_features.sample}" }

  before do
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
  end

  describe "#parse" do

    context "when simple feature" do
      it "should succeed for available features" do
        @avail_features.each { |feature| assert_parse("f?#{feature}") }
      end

      it "should fail for unavailable features" do
        @unavail_features.each { |feature| assert_not_parse("f?#{feature}") }
      end
    end

    context "when simple variable" do
      it "should succeed for available variables" do
        @avail_vars.each { |variable| assert_parse("v?#{variable}") }
      end

      it "should fail for unavailable variables" do
        @unavail_vars.each { |variable| assert_not_parse("v?#{variable}") }
      end
    end

    context "when combined features" do


      [ "#{avail_feature} && #{avail_feature}",
        "#{unavail_feature} || #{avail_feature}"
      ].each do |expression|
        context "when features are available" do
          subject { expression }
          it { is_expected.to be_evaluated_as_true(@vars_mock) }
        end
      end

      [ "#{unavail_feature} && #{avail_feature}",
        "#{unavail_feature} || #{unavail_feature}"
      ].each do |expression|
        context "when features are unavailable" do
          subject { expression }
          it { is_expected.to be_evaluated_as_true(@vars_mock) }
        end
      end

    end

    context "when conditions are nested" do

      [ "#{avail_var} && (#{avail_var} || #{unavail_var})",
        "(#{avail_var} && #{avail_var}) && (#{avail_var} || #{unavail_var})"
      ].each do |expression|
        context "when using only variables: #{expression}" do
          subject { expression }
          it { is_expected.to be_evaluated_as_true(@vars_mock) }
        end
      end

      [ "#{avail_feature} && (#{avail_feature} || #{unavail_feature})",
        "(#{avail_feature} && #{avail_feature}) && (#{avail_feature} || #{unavail_feature})"
      ].each do |expression|
        context "when using only features: #{expression}" do
          subject { expression }
          it { is_expected.to be_evaluated_as_true(@vars_mock) }
        end
      end

      context "when using both variables and features" do
        subject { "(#{avail_var} && #{avail_feature}) && (#{unavail_feature} || (#{avail_var} || #{unavail_feature}))" }
        it { is_expected.to be_evaluated_as_true(@vars_mock) }
      end

    end

  end

end
