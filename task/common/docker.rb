def docker_image?(image_name)
  !`docker images -q #{image_name}`.strip.empty?
end

def docker_container?(container_name)
  !`docker ps -q -f name=#{container_name}`.strip.empty?
end

def docker_build(image_name)
  dockerfile_path = $cfg[:paths][:docker].join("Dockerfile")
  sh("docker build -f #{dockerfile_path} -t #{image_name} .", verbose: true)
end

def docker_run(image_name, cmd)
  container_name = image_name
  unless docker_container?(container_name)
    sh("docker run --rm --name #{container_name} -d -it #{image_name}",
       verbose: true)
  end

  sh "docker exec -it #{container_name} #{cmd}", verbose: true
end
