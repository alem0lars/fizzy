# Core modules.
require "fileutils"
require "find"
require "ostruct"
require "net/http"
require "pathname"
require "yaml"
require "json"

# Try to require `thor` or raise an exception.
begin
  require "thor"
rescue
  puts("\e[31m☠ The gem `thor` is not installed. " \
       "To install run: `gem install thor`. Aborting.\e[0m")
  exit(-1)
end

# Top-level namespace.
module Fizzy
end
