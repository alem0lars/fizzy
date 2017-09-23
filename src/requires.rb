# Core modules.
require "English"
require "fileutils"
require "find"
require "forwardable"
require "json"
require "net/http"
require "optparse"
require "optparse/date"
require "optparse/time"
require "ostruct"
require "pathname"
require "securerandom"
require "singleton"
require "shellwords"
require "strscan"
require "uri"
require "yaml"

begin
  require "readline"
rescue LoadError
  puts("\e[33m☞ The library `readline` is not available. Falling back..")
end

# Lazy-load `io/console` since it is gem-ified as of `2.3`.
require "io/console" if RUBY_VERSION > "1.9.2"

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

#
# Top-level namespace.
#
module Fizzy
end
