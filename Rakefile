require "erb"
require "net/http"
require "ostruct"
require "yaml"
require "pathname"
require "shellwords"
require "uri"

# require "bundler/setup" # For `Bundler.with_clean_env`.

Bundler.require(:default, :development)

$:.unshift(File.dirname(__FILE__))
require "task/common/funcs"
require "task/common/cfg"
require "task/common/erb"
require "task/common/bin_util"
require "task/common/grammars"
require "task/common/package"
require "task/common/docker"
Rake.add_rakelib("task")
