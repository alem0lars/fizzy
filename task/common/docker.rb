def docker_image?(image_name)
  !`docker images -q #{image_name}`.strip.empty?
end

def docker_container?(container_name)
  !`docker ps -q -f name=#{container_name}`.strip.empty?
end

def docker_build(image_name)
  dockerfile_path = $cfg[:paths][:docker].join("Dockerfile")
  cmd = "docker build -f #{dockerfile_path} -t #{image_name} ."
  fill_cmd_with_docker_args(cmd)
  sh(cmd, verbose: true)
end

def docker_run(image_name, cmd)
  container_name = image_name
  unless docker_container?(container_name)
    cmd = "docker run --rm --name #{container_name} -d -it #{image_name}"
    fill_cmd_with_docker_args(cmd)
    sh(cmd, verbose: true)
  end

  sh "docker exec -it #{container_name} #{cmd}", verbose: true
end

DOCKER_ARGS = %w[
  RUBY_MAJOR
  RUBY_MINOR
  RUBY_MATCH
  RUBY_OTHER
  RUBY_SHA256
  RUBYGEMS_FULL_VERSION
].freeze

def fill_cmd_with_docker_args(cmd)
  DOCKER_ARGS.each do |env_var_name|
    if ENV[env_var_name]
      cmd << " --build-arg=#{env_var_name}=#{ENV[env_var_name]}"
    end
  end
end
