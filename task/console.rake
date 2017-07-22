namespace :docker do
  desc "Start a console inside the docker container"
  task console: :prepare do
    ENV["DOCKER_SILENT_BUILD"] = "true"
    docker_run("fizzy", "/bin/zsh")
  end
end
