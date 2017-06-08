# ☞ Download archives.
runtimes_info.each do |runtime_info|
  file runtime_info[:rel_path] do
    download_runtime(runtime_info[:name], runtime_info[:path])
  end
end

task package: [:build] + runtimes_info.map{|r_i| r_i[:rel_path]} do
  info "Packaging started"

  runtimes_info.each do |runtime_info|
    create_package(runtime_info[:name],
                   runtime_info[:path],
                   runtime_info[:dst_path])
  end

  info "Packaging successfully completed", success: true
end
