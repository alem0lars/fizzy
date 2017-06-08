namespace :docker do
  desc "Prepare docker container for fizzy"
  task :prepare do
    docker_build "fizzy"
  end
end
