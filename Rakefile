# ──────────────────────────────────────────────────────────────────────────────
# ☞ Requires

require "net/http"
require "yaml"
require "pathname"
require "shellwords"
require "uri"

require "bundler/setup" # For `Bundler.with_clean_env`.

Bundler.require(:development)

require "rake/testtask"

$:.unshift(File.dirname(__FILE__))
require "tasks/funcs"
require "tasks/cfg"
require "tasks/bin_utils"
require "tasks/grammars"
require "tasks/package"
require "tasks/docker"

# ──────────────────────────────────────────────────────────────────────────────
# ☞ Task `default`

task default: :build

# ──────────────────────────────────────────────────────────────────────────────
# ☞ Task `build`

desc "Build Fizzy"
task :build do
  info("Build started")

  # ☞ Initial cleanup.
  cleanup_bin

  # ☞ Build grammars.
  build_grammars

  # ☞ Write preamble.
  write_bin("HashBang", $cfg[:hashbang], newlines: 2)
  write_bin("Header",   $cfg[:header],   newlines: 1)

  # ☞ Write source files content.
  $cfg[:sources].each do |src_file_name|
    src_file_path = Pathname.new(src_file_name)
    if src_file_path.absolute?
      src_file_name = src_file_path.basename(src_file_path.extname)
    else
      src_file_path = $cfg[:paths][:src].join("#{src_file_path}.rb")
    end
    src_file_name = src_file_name.to_s

    section_title = titleize_file_name(src_file_name)
    write_bin("Separator for section `#{src_file_name}`",
              "# #{"─" * 78}\n# ☞ #{section_title}",
              newlines: [1, 2])
    write_bin("Content of file `#{src_file_name}`", src_file_path.read)
  end

  # ☞ Cleanup temporary files.
  $cfg[:sources].select { |name| name.to_s =~ /^#{$cfg[:paths][:tmp].to_s}/ }.
                 each   { |tmp_file| tmp_file.delete                        }

  # ☞ Set executable permissions.
  $cfg[:paths][:bin].chmod 0775

  # ☞ Link to a `.rb` file (mainly used for testing purposes).
  $cfg[:paths][:bin_rb].unlink if $cfg[:paths][:bin_rb].symlink?
  $cfg[:paths][:bin_rb].make_symlink($cfg[:paths][:bin])

  info("Build successfully completed", success: true)
end

# ──────────────────────────────────────────────────────────────────────────────
# ☞ Task `package`

# ☞ Download archives.
runtimes_info.each do |runtime_info|
  file runtime_info[:rel_path] do
    download_runtime(runtime_info[:name], runtime_info[:path])
  end
end

task package: [:build] + runtimes_info.map{|r_i| r_i[:rel_path]} do
  info("Packaging started")

  runtimes_info.each do |runtime_info|
    create_package(runtime_info[:name],
                   runtime_info[:path],
                   runtime_info[:dst_path])
  end

  info("Packaging successfully completed", success: true)
end

# ──────────────────────────────────────────────────────────────────────────────
# ☞ Task `run`

task run: :build do |t, args|
  cmd = $cfg[:paths][:bin].to_s
  cmd_env_var_name = "CMD"
  debug("Reading command from environment variable: `#{cmd_env_var_name}`.")
  args = ENV[cmd_env_var_name] || error("Invalid command: not provided")

  if args.empty?
    exec(cmd)
  else
    exec(cmd, *args)
  end
end

# ──────────────────────────────────────────────────────────────────────────────
# ☞ Task `test`

Rake::TestTask.new do |t|
  t.libs += [$cfg[:paths][:build], $cfg[:paths][:test]]
  t.test_files = FileList[$cfg[:paths][:test].join("test_*.rb")]
  t.verbose = true
end

task test: :build

# ──────────────────────────────────────────────────────────────────────────────
# ☞ Task `doc`

namespace :doc do
  YARD::Rake::YardocTask.new do |t|
    t.name = "generate"
  end
  #   t.files = ["src/**/*.rb", "-", "CHANGELOG.md"]#] + Dir["*.md"].reject{|e| e == $cfg[:api_doc][:main]}
  #   # t.options = %W[
  #   #   --markup-provider #{$cfg[:api_doc][:markup][:provider]}
  #   #   --markup #{$cfg[:api_doc][:markup][:name]}
  #   #   --main #{$cfg[:api_doc][:main]}
  #   # ]
  # end
  desc "Run a local documentation server"
  task server: "doc:generate" do
    sh "yard server --reload"
  end
end

# ──────────────────────────────────────────────────────────────────────────────
# ☞ Task `console`

task console: :build do
  sh("irb -I . -r build/fizzy")
end

# ──────────────────────────────────────────────────────────────────────────────
# ☞ Tasks inside `docker`

namespace :docker do
  desc "Prepare docker container for fizzy"
  task :prepare do
    if !docker_image?("fizzy") || truthy_env_var?("FIZZY_DOCKER_BUILD")
      docker_build("fizzy")
    end
  end

  desc "Test fizzy inside the docker container"
  task test: :prepare do
    docker_run("fizzy", "rake test")
  end

  desc "Start a console inside the docker container"
  task console: :prepare do
    docker_run("fizzy", "/bin/bash")
  end
end
