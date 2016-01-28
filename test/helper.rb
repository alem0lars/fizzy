# Helper module for writing unit tests and mock objects.
#
# You need to require this module at the very first `require`.
#
# Example:
#
#   require "helper"
#
#   class Fizzy::Tests::Foo < Test::Unit::TestCase
#     def test_first
#       # ...
#     end
#   end
#

require "test/unit"
require "fizzy"

# Setup mocks.
module Fizzy::Mocks end
Dir.glob(File.join(File.dirname(__FILE__), "mocks", "*.rb")) do |module_path|
  require module_path
end

# Setup tests.
module Fizzy::Tests end
