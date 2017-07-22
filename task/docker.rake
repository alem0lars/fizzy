namespace :docker do
  desc "Prepare docker container for fizzy"
  task :prepare do
    docker_build("fizzy", silent: ENV["DOCKER_SILENT_BUILD"] == "true")
  end
end
