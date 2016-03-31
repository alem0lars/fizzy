source "https://rubygems.org"

# The "real" fizzy dependencies.
group :production do
  gem "thor"
end

# External tools used **only** during development.
group :development do
  # Used to define common tasks.
  gem "rake"

  # Used for generating ruby code from the grammars definitions.
  gem "racc", "~> 1.4"

  # Used to perform tests.
  gem "minitest"

  # Make IRB more powerful!
  gem "irbtools"
  gem "irbtools-more"
end
