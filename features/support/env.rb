root_dir = Pathname.new(__FILE__).expand_path.dirname.dirname.dirname
spec_dir = root_dir.join("spec")

$LOAD_PATH.unshift(spec_dir.to_s) unless $LOAD_PATH.include?(spec_dir.to_s)

require "rspec"
require "spec_helper"
