namespace :docker do
  desc "Start a console inside the docker container"
  task console: :prepare do
    docker_run "fizzy", "/bin/zsh"
  end
end
