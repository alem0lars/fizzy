require "spec_helper"


describe Fizzy::TypeParser do

  include_context :grammars_type

  describe "#parse" do

#    context "when leaf type" do
#      subject { "int" }
#      it { is_expected.to be_evaluated_as_true }
#    end

#    context "when simple list" do
#      subject { "list<int>" }
#      it { is_expected.to be_evaluated_as_true }
#    end

#    context "when simple list (brackets form)" do
#      subject { "[int]" }
#      it { is_expected.to be_evaluated_as_true }
#    end

    context "when list of lists" do
      subject { "[[[int]]]" }
      it { is_expected.to be_evaluated_as_true }
    end

#    context "when list of lists" do
#      subject { "list<list<list<int>>>" }
#      it { is_expected.to be_evaluated_as_true }
#    end
  end
end
