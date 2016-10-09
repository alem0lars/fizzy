shared_context :grammars_type do

  let(:parser) { Fizzy::TypeParser.new }

  matcher :be_evaluated_as_true do |untyped_value|
    match do |type_expression|
      parser.parse(untyped_value, type_expression)
    end

    description do
      "be evaluated as true"
    end
  end

end
