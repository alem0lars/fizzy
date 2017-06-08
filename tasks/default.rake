task :default do
  info "Listing available rake tasks"
  sh "rake -sT", verbose: false
end
