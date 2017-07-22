require "spec_helper"


# TODO: Use shared examples (if it makes sense)
# describe Fizzy::TypeParser do
#
#   include_context :grammars_type
#
#   describe "#parse" do
#
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

    # context "when list of lists" do
    #   subject { "[[[int]]]" }
    #   it { is_expected.to be_evaluated_as_true }
    # end

#   context "when list of lists" do
#     subject               {  [ [ [ 10,  20  ] ] ] }
#     let(:expected)        {  [ [ [ 10, "20" ] ] ] }
#     let(:type_expression) { "list<list<list<int, string>>>" }
#     it { is_expected.to be_evaluated_as(expected, using: type_expression) }
#   end
#   end
# end
