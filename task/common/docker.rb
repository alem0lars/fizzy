# Allowed docker arguments.
#
DOCKER_ARGS = %w[
  RUBY_MAJOR
  RUBY_MINOR
  RUBY_MATCH
  RUBY_OTHER
  RUBY_SHA256
  RUBYGEMS_FULL_VERSION
].freeze

# Check if a docker image with provided name exists.
#
def docker_image?(image_name)
  !`docker images -q #{image_name}`.strip.empty?
end

# Check if a docker container with provided name is running.
#
def docker_container?(container_name)
  !`docker ps -q -f name=#{container_name}`.strip.empty?
end

# Build a docker image, assuming current working directory contains the
# Dockerfile needed.
#
def docker_build(image_name, silent: false)
  dockerfile_path = $cfg[:paths][:docker].join("Dockerfile")
  cmd = "docker build"
  cmd << " -q" if silent
  cmd << " -f #{dockerfile_path}"
  cmd << " -t #{image_name}"
  cmd << " ."
  fill_cmd_with_docker_args(cmd)
  sh(cmd, verbose: true)
end

# Run the provided command into a docker container created from image
# `image_name`, having the same name.
#
def docker_run(image_name, container_cmd)
  container_name = image_name

  unless docker_container?(container_name)
    cmd = "docker run"
    cmd << " --rm"
    cmd << " --name #{container_name}"
    cmd << " -d"
    cmd << " -it"
    cmd << " #{image_name}"
    sh(cmd, verbose: true)
  end

  sh("docker exec -it #{container_name} #{container_cmd}", verbose: true)
end

# Fill the provided command with some arguments.
#
def fill_cmd_with_docker_args(cmd)
  DOCKER_ARGS.each do |env_var_name|
    if ENV[env_var_name]
      cmd << " --build-arg=#{env_var_name}=#{ENV[env_var_name]}"
    end
  end
end
