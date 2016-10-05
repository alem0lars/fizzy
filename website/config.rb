set :build_dir, "../docs"

# TODO: Add prefix in build to docs so it will be served relative do docs

# Per-page layout changes:
#
# With no layout
page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false

# Reload the browser automatically whenever files change
require "middleman-livereload"
configure :development do
  activate :livereload
end

# Change the asset's filename every time you change one of your assets.
activate :asset_hash

# Create a folder for each `.html` file and place the built template file as
# the index of that folder.
# activate :directory_indexes

# Manage assets with sprockets.
require "sprockets/es6"
require "middleman-sprockets"
activate :sprockets do |c|
  c.expose_middleman_helpers = true
  c.supported_output_extensions << ".es6"
end
sprockets.append_path File.join root, "bower_components"

# Development-specific configuration.
configure :development do
  set :debug_assets, true
end

# Build-specific configuration.
configure :build do
  set :https, true
  set :http_prefix, "/docs"

  # Minify CSS on build.
  activate :minify_css

  # Minify Javascript on build.
  activate :minify_javascript

  # Serve compressed files to user agents that can handle it.
  activate :gzip
end
