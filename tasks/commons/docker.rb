def docker_image?(image_name)
  !`docker images -q #{image_name}`.strip.empty?
end

def docker_build(image_name)
  dockerfile_path = $cfg[:paths][:docker].join("Dockerfile")
  sh "docker build -f #{dockerfile_path} -t #{image_name} .", verbose: false
end

def docker_run(image_name, cmd)
  sh "docker run -i -t #{image_name} #{cmd}", verbose: false
end
