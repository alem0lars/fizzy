# Core modules.
require "fileutils"
require "find"
require "forwardable"
require "json"
require "net/http"
require "ostruct"
require "pathname"
require "securerandom"
require "shellwords"
require "strscan"
require "uri"
require "yaml"

# Load external dependencies.
%w(thor).each do |gem_name|
  begin
    require gem_name
  rescue
    puts("\e[31m☠ The gem `#{gem_name}` is not installed. " +
        "To install run: `gem install #{gem_name}`. Aborting.\e[0m")
    exit(-1)
  end
end

# Top-level namespace.
module Fizzy
end
