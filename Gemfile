source "https://rubygems.org"

gem "thor"

# External tools used **only** during development.
group :development do

  # Define tasks.
  gem "rake", require: false

  # Generate ruby code from the grammars definitions.
  gem "racc", require: false

  # Lint.
  gem "rainbow", "=2.0", require: false # XXX workaround, see issue #44.
  gem "rubocop",         require: false
  gem "rubocop-rspec",   require: false

  # Testing.
  gem "rspec",    require: false
  gem "fuubar",   require: false
  gem "cucumber", require: false

  # Improve IRB, adding some features.
  gem "irbtools", require: "irbtools/binding"

  # Print inspected Ruby objects; useful when debugging.
  gem "awesome_print"

  # Generate API documentation.
  gem "yard"
  gem "kramdown"

  # Debugger.
  gem "byebug"

  # Code coverage.
  gem "simplecov"

end

group :website do
  # For faster file watcher updates on Windows.
  gem "wdm", "~> 0.1.0", platforms: [:mswin, :mingw]

  # Windows does not come with time zone data.
  gem "tzinfo-data", platforms: [:mswin, :mingw, :jruby]

  # Middleman gems.
  gem "middleman", ">= 4.0.0"
  gem "middleman-livereload"
  gem "middleman-sprockets"
  gem "sprockets-es6"

  # Twitter Bootstrap.
  gem "bootstrap", "~> 4.0.0.alpha3"
  source "https://rails-assets.org" do
    gem "rails-assets-tether", ">= 1.1.0"
  end
end
