source "https://rubygems.org"

# TODO remove just before release `3.0.0`.
gem "thor"

# External tools used **only** during development.
group :development do
  # Define tasks.
  gem "rake", require: false

  # Generate ruby code from the grammars definitions.
  gem "racc", require: false

  # Lint.
  #gem "rainbow", "=2.0", require: false # XXX workaround, see issue #44.
  gem "rufo", require: false

  # Testing frameworks.
  gem "cucumber", require: false
  gem "fuubar",   require: false
  gem "rspec",    require: false

  # Improve IRB, adding some features.
  gem "irbtools", require: "irbtools/binding"

  # Print inspected Ruby objects; useful when debugging.
  gem "awesome_print"

  # Generate API documentation.
  gem "kramdown"
  gem "yard"

  # Debugger.
  gem "byebug"

  # Code coverage.
  gem "simplecov"
end
