shared_context :docker do

  def self.just_in_docker
    if in_docker?
      yield
    else
      skip ".. not inside a docker container: skipping .."
    end
  end

  def self.in_docker?
    cgroup_path = Pathname.new("/proc/self/cgroup")
    return false unless cgroup_path.file?
    cgroup_path.readlines.any? do |line|
      line.split(":")[2].start_with?("/docker")
    end
  end

end
