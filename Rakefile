# ──────────────────────────────────────────────────────────────────────────────
# ☞ Requires

require "net/http"
require "yaml"
require "pathname"
require "shellwords"
require "uri"

require "bundler/setup" # For `Bundler.with_clean_env`.
require "rake/testtask"

$:.unshift(File.dirname(__FILE__))
require "tasks/funcs"
require "tasks/cfg"
require "tasks/bin_utils"
require "tasks/grammars"
require "tasks/package"

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

task :package => [:build] + runtimes_info.map{|r_i| r_i[:rel_path]} do
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
  args = std_args.map { |arg| Shellwords.escape(arg) }.join(" ")

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
# ☞ Task `console`

task console: :build do
  system("irb -I . -r build/fizzy")
end
