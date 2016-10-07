shared_context :docker do

  def self.skip_unless_in_docker(&block)
    unless in_docker?
      skip(".. not inside a docker container: skipping ..", &block)
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
