set :build_dir, "../doc"

# TODO: Add prefix in build to `doc` so it will be served relative do `doc`

# ─────────────────────────────────────────────────── Per-page layout changes ──

# Without layout
page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false

# ────────────────────────────────────────────────────────────────────── Misc ──

# Change the asset's filename every time you change one of your assets.
activate :asset_hash

# Create a folder for each `.html` file and place the built template file as
# the index of that folder.
activate :directory_indexes

# ──────────────────────────────────────── Development-specific configuration ──

configure :development do
  set :debug_assets, true
end

# ────────────────────────────────────────────── Build-specific configuration ──

configure :build do
  # Set the prefix used in production.
  set :http_prefix, "/docs"

  # Minify CSS on build.
  activate :minify_css

  # Minify Javascript on build.
  activate :minify_javascript

  # Serve compressed files to user agents that can handle it.
  activate :gzip
end

# ────────────────────────────────────────────────────────────────── Pipeline ──

activate :external_pipeline,
         name: :webpack,
         command: build? ?
                  %w[
                    FIZZY_ENV=production
                    ./node_modules/webpack/bin/webpack.js
                    --bail
                    -p
                  ].join(" ") :
                  %w[
                    FIZZY_ENV=development
                    ./node_modules/webpack/bin/webpack.js
                    --watch
                    -d
                    --progress
                    --color
                  ].join(" "),
         source: "./tmp/dist",
         latency: 1
