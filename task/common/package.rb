def runtimes_info
  fizzy_vers = $cfg[:version]
  archs = $cfg[:traveling_ruby][:archs]
  traveling_vers = $cfg[:traveling_ruby][:vers]
  ruby_vers = $cfg[:traveling_ruby][:ruby_vers]
  ext = ".tar.gz"

  runtimes_info = []
  archs.each do |os, archs|
    archs = [nil] if archs.nil?
    archs.each do |arch|
      name = runtime_name(traveling_vers, ruby_vers, os, arch)
      path = $cfg[:paths][:tmp].join("#{name}#{ext}")

      runtimes_info << {
        traveling_vers: traveling_vers,
        ruby_vers: ruby_vers,
        os: os,
        arch: arch,
        name: name,
        path: path,
        rel_path: path.relative_path_from($cfg[:paths][:root]),
        dst_path: $cfg[:paths][:pkg].join([
          "fizzy-portable-v#{fizzy_vers}",
          "ruby-v#{ruby_vers}",
          os,
          arch
        ].compact.join("_") + ext)
      }
    end
  end
  runtimes_info
end

def runtime_name(traveling_vers, ruby_vers, os, arch)
  name = "#{traveling_vers}-#{ruby_vers}-#{os}"
  name << "-#{arch}" if arch
  name
end

def download_runtime(runtime_name, dst_path)
  runtime_archive_name = "#{runtime_name}.tar.gz"
  src_name = "traveling-ruby-#{runtime_archive_name}"
  info("Downloading runtime: #{runtime_name}", indent: 1)
  url = URI.join("https://d6r77u77i8pq3.cloudfront.net/releases/#{src_name}")
  res = Net::HTTP.get_response(url)
  if res.is_a?(Net::HTTPSuccess)
    File.write(dst_path, res.body)
    info("Runtime successfully downloaded", indent: 1, success: true)
  else
    error("Network error: cannot retrieve `#{url}`.")
  end
end

def create_package(runtime, runtime_path, dst_path)
  package_path = $cfg[:paths][:tmp].join("#{runtime}_tmp")
  package_lib_path = package_path.join("lib")
  package_app_path = package_lib_path.join("app")
  package_ruby_path = package_lib_path.join("ruby")
  package_vendor_path = package_lib_path.join("vendor")
  package_bundle_path = package_vendor_path.join(".bundle")
  package_launcher_path = package_path.join($cfg[:paths][:bin].basename)
  gemfile_path = $cfg[:paths][:root].join("Gemfile")
  gemfile_lock_path = $cfg[:paths][:root].join("Gemfile.lock")
  tmp_vendor_path = $cfg[:paths][:tmp].join("vendor")

  # Remove previous package.
  package_path.rmtree if package_path.exist?

  # Add the app.
  package_app_path.mkpath
  FileUtils.cp($cfg[:paths][:bin], package_app_path)

  # Add the ruby interpreter.
  package_ruby_path.mkpath
  sh "tar -xzf #{runtime_path} -C #{package_ruby_path}"

  # Build gems declared in Gemfile.
  FileUtils.cp(gemfile_path, $cfg[:paths][:tmp])
  FileUtils.cp(gemfile_lock_path, $cfg[:paths][:tmp])
  Bundler.with_clean_env do
    FileUtils.cd($cfg[:paths][:tmp]) do
      sh("BUNDLE_IGNORE_CONFIG=1 " \
         "bundle install " \
         "--path #{tmp_vendor_path} " \
         "--without development")
    end
  end
  # Remove cache files.
  Pathname.glob(tmp_vendor_path.join("*", "*", "cache", "*")).each do |path|
    path.unlink if path.exist?
  end
  # Copy gems to destination.
  FileUtils.cp_r(tmp_vendor_path, package_lib_path, preserve: true)

  # Add bundler Gemfile.
  FileUtils.cp(gemfile_path, package_vendor_path)
  FileUtils.cp(gemfile_lock_path, package_vendor_path)
  tmp_vendor_path.rmtree if tmp_vendor_path.exist?

  # Add bundler config file.
  package_bundle_path.mkdir
  package_bundle_path.join("config").write([
    "BUNDLE_PATH: .",
    "BUNDLE_WITHOUT: development",
    "BUNDLE_DISABLE_SHARED_GEMS: '1'"
  ].join("\n"))

  # Add launcher.
  package_launcher_path.write([
    "#!/bin/bash",
    "set -e",
    # Figure out where this script is located.
    "SELFDIR=\"`dirname \\\"$0\\\"`\"",
    "SELFDIR=\"`cd \\\"$SELFDIR\\\" && pwd`\"",
    # Tell Bundler where the Gemfile and gems are.
    "export BUNDLE_GEMFILE=\"$SELFDIR/lib/vendor/Gemfile\"",
    "unset BUNDLE_IGNORE_CONFIG",
    # Run the actual app using the bundled Ruby interpreter, with Bundler activated.
    "exec \"$SELFDIR/lib/ruby/bin/ruby\" -rbundler/setup \"$SELFDIR/lib/app/#{$cfg[:paths][:bin].basename}\""
  ].join("\n"))

  unless ENV["DIR_ONLY"]
    # Create an archive containing the created runtime.
    FileUtils.cd(package_path) do
      sh("tar -czf #{dst_path} *")
    end
    package_path.rmtree if package_path.exist?
  end
end
