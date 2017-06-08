module Fizzy::Mocks
  class Meta
    include Fizzy::Meta::Info

    def initialize(content)
      vars_name = SecureRandom.hex
      ENV[vars_name] = content.to_json
      setup_vars(nil, vars_name)
    end
  end
end
