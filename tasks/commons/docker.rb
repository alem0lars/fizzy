def docker_image?(image_name)
  !`docker images -q #{image_name}`.strip.empty?
end

def docker_build(image_name)
  sh "docker build -t #{image_name} ."
end

def docker_run(image_name, cmd)
  sh "docker run -i -t #{image_name} #{cmd}"
end
