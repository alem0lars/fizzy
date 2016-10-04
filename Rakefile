require "erb"
require "net/http"
require "ostruct"
require "yaml"
require "pathname"
require "shellwords"
require "uri"

require "bundler/setup" # For `Bundler.with_clean_env`.

Bundler.require(:default, :development)

$:.unshift(File.dirname(__FILE__))
require "tasks/commons/funcs"
require "tasks/commons/cfg"
require "tasks/commons/erb"
require "tasks/commons/bin_utils"
require "tasks/commons/grammars"
require "tasks/commons/package"
require "tasks/commons/docker"
Rake.add_rakelib "tasks"
