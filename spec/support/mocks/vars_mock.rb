module Fizzy::Mocks
  class Vars
    include Fizzy::Vars

    def initialize(content)
      vars_name = SecureRandom.hex
      ENV[vars_name] = content.to_json
      setup_vars(nil, vars_name)
    end
  end
end
