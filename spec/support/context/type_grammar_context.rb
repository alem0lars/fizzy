shared_context :type_grammar do
  let(:parser) { Fizzy::TypeParser.new }

  matcher :be_evaluated_as do |expected, using: nil|
    match do |untyped_value|
      expect(parser.parse(untyped_value, using)).to eq(expected)
    end

    description do
      "be evaluated `#{expected}` using type expression `#{using}`"
    end
  end
end
