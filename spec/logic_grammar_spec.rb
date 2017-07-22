require "spec_helper"

describe Fizzy::LogicParser do
  include_context :logic_grammar
  include_context :output

  before { silence_output }
  after { enable_output }

  class << self
    def avail_features
      %w[accu amun-ra corr_disc the-eme_ward]
    end

    def unavail_features
      %w[arti amun_ra corr-disc the-eme-ward empath]
    end

    def avail_vars
      %w[arte doc-rep flint_beast keep-of_the.lake]
    end

    def unavail_vars
      %w[accu doc_rep flint-beast keep_of_the.lake ophe]
    end

    def avail_var_expression
      "v?#{avail_vars.sample}"
    end

    def avail_feature_expression
      "f?#{avail_features.sample}"
    end

    def unavail_var_expression
      "v?#{unavail_vars.sample}"
    end

    def unavail_feature_expression
      "f?#{unavail_features.sample}"
    end
  end

  let(:vars_mock) do
    Fizzy::Mock::Vars.new("arte" => "agility",
      "arti"        => "agility",
      "balpha"      => "strength",
      "doc-rep"     => "intelligence",
      "flint_beast" => "agility",
      "keep-of_the" => {
          "lake" => "strength",
        "street" => "strength"
      },
      features: %w[accu aluna andro amun-ra corr_disc the-eme_ward])
  end

  describe "#parse" do
    context "when simple feature" do
      avail_features.each do |feature|
        context "`#{feature}` is available" do
          subject { "f?#{feature}" }

          it { is_expected.to be_evaluated_as_true(vars_mock) }
        end
      end

      unavail_features.each do |feature|
        context "`#{feature}` is unavailable" do
          subject { "f?#{feature}" }

          it { is_expected.not_to be_evaluated_as_true(vars_mock) }
        end
      end
    end

    context "when simple variable" do
      avail_vars.each do |variable|
        context "`#{variable}` is available" do
          subject { "v?#{variable}" }

          it { is_expected.to be_evaluated_as_true(vars_mock) }
        end
      end

      unavail_vars.each do |variable|
        context "`#{variable}` is unavailable" do
          subject { "v?#{variable}" }

          it { is_expected.not_to be_evaluated_as_true(vars_mock) }
        end
      end
    end

    context "when combined features" do
      ["#{avail_feature_expression} && #{avail_feature_expression}",
       "#{unavail_feature_expression} || #{avail_feature_expression}"].each do |expression|
        context "when features are available" do
          subject { expression }

          it { is_expected.to be_evaluated_as_true(vars_mock) }
        end
      end

      ["#{unavail_feature_expression} && #{avail_feature_expression}",
       "#{unavail_feature_expression} || #{unavail_feature_expression}"].each do |expression|
        context "when features are unavailable" do
          subject { expression }

          it { is_expected.not_to be_evaluated_as_true(vars_mock) }
        end
      end
    end

    context "when conditions are nested" do
      ["#{avail_var_expression} && (#{avail_var_expression} || #{unavail_var_expression})",
       "(#{avail_var_expression} && #{avail_var_expression}) && (#{avail_var_expression} || #{unavail_var_expression})"].each do |expression|
        context "when is logically equivalent to true: #{expression}" do
          subject { expression }

          it { is_expected.to be_evaluated_as_true(vars_mock) }
        end
      end
    end

    context "when conditions are nested" do
      ["#{avail_var_expression} && (#{avail_var_expression} || #{unavail_var_expression})",
       "(#{avail_var_expression} && #{avail_var_expression}) && (#{avail_var_expression} || #{unavail_var_expression})",
       "#{avail_feature_expression} && (#{avail_feature_expression} || #{unavail_feature_expression})",
       "(#{avail_feature_expression} && #{avail_feature_expression}) && (#{avail_feature_expression} || #{unavail_feature_expression})",
       "(#{avail_var_expression} && #{avail_feature_expression}) && (#{unavail_feature_expression} || (#{avail_var_expression} || #{unavail_feature_expression}))"].each do |expression|
        context "when is logically equivalent to true: #{expression}" do
          subject { expression }

          it { is_expected.to be_evaluated_as_true(vars_mock) }
        end
      end
    end
  end
end
