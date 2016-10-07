shared_context :grammars_logic do

  let(:parser) { Fizzy::LogicParser.new }

  RSpec::Matchers.define :be_evaluated_as_true do |vars|
    match do |actual|
      parser.parse(vars, actual)
    end
    description do
      "be evaluated as true"
    end
  end

end
