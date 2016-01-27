# Core modules.
require "fileutils"
require "find"
require "json"
require "net/http"
require "ostruct"
require "pathname"
require "shellwords"
require "strscan"
require "uri"
require "yaml"

# Try to require `thor` or raise an exception.
begin
  require "thor"
rescue
  puts("\e[31m☠ The gem `thor` is not installed. " +
       "To install run: `gem install thor`. Aborting.\e[0m")
  exit(-1)
end

# Top-level namespace.
module Fizzy
end
