shared_context :logic_grammar do
  let(:parser) { Fizzy::LogicParser.new }

  matcher :be_evaluated_as_true do |vars|
    match do |actual|
      parser.parse(vars, actual)
    end
    description do
      "be evaluated as true"
    end
  end
end
