# Helper module for writing unit tests and mock objects.
#
# You need to require this module at the very first `require`.
#
# Example:
#
#   require "helper"
#
#   describe MyClass
#     it "should ..." { ... }
#   end
#

# Require gems available only when testing.
require "awesome_print"

require "minitest/autorun"
require "fizzy"

# Setup mocks.
module Fizzy::Mocks end
Dir.glob(File.join(File.dirname(__FILE__), "mocks", "*.rb")) do |module_path|
  require module_path
end

# Setup testing utilities.
module Fizzy::TestUtils end
Dir.glob(File.join(File.dirname(__FILE__), "utils", "*.rb")) do |module_path|
  require module_path
end
