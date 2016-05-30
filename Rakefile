# ┌────────────────────────────────────────────────────────────────────────────┐
# ├→ Requires ─────────────────────────────────────────────────────────────────┤

require "net/http"
require "yaml"
require "pathname"
require "shellwords"
require "uri"

require "bundler/setup" # For `Bundler.with_clean_env`.
require "rake/testtask"

# ├────────────────────────────────────────────────────────────────────────────┤
# ├→ Configuration ────────────────────────────────────────────────────────────┤

DEBUG = ENV["FIZZY_DEBUG"] == "true"

ROOT_PATH     = Pathname.new(File.dirname(__FILE__))
BUILD_PATH    = ROOT_PATH.join("build")
PKG_PATH      = BUILD_PATH.join("package")
TMP_PATH      = ROOT_PATH.join("tmp")
TEST_PATH     = ROOT_PATH.join("test")
SRC_PATH      = ROOT_PATH.join("src")
GRAMMARS_PATH = SRC_PATH.join("grammars")

OLD_BIN_PATH = BUILD_PATH.join("fizzy-old")
BIN_PATH     = BUILD_PATH.join("fizzy")
BIN_RB_PATH  = Pathname.new("#{BIN_PATH}.rb")

BUILD_CFG_PATH = ROOT_PATH.join("build-cfg.yaml")

GRAMMARS_SOURCE_NAME = "<grammars>"

# ├────────────────────────────────────────────────────────────────────────────┤
# ├→ Utils ────────────────────────────────────────────────────────────────────┤

def info(msg, indent: 0, success: false)
  puts(("\t" * indent) + "☞ " + "\e[#{success ? 32 : 34}m#{msg}\e[0m")
end

def error(msg)
  puts("\e[31m☠ Error: #{msg}\e[0m")
  exit(-1)
end

# ├────────────────────────────────────────────────────────────────────────────┤
# ├→ Task `build` ─────────────────────────────────────────────────────────────┤

def write_bin(title, content, newlines: [0, 0], mode: "a")
  BIN_PATH.open(mode) do |bin_file|
    info("Filling binary with: #{title}", indent: 1) if title && !title.empty?
    content = "" if content.nil?
    if newlines.is_a?(Array) && newlines.length == 2
      content = ("\n" * newlines.first) + content + ("\n" * newlines.last)
    elsif newlines.is_a?(Fixnum)
      content = content + ("\n" * newlines)
    else
      error "Invalid argument `newlines`: expected to be a 2-ple or number"
    end
    bin_file.write(content)
  end
end

def load_build_cfg
  info("Loading build configuration")

  # ☛ Check tmp directory
  error("The temporary directory `#{TMP_PATH}` is reserved") if TMP_PATH.file?
  TMP_PATH.mkdir unless TMP_PATH.directory?
  # ☛ Check build directory
  error("The build directory `#{BUILD_PATH}` is reserved") if BUILD_PATH.file?
  BUILD_PATH.mkdir unless BUILD_PATH.directory?
  # ☛ Check pkg directory
  error("The package directory `#{PKG_PATH}` is reserved") if PKG_PATH.file?
  PKG_PATH.mkdir unless PKG_PATH.directory?
  # ☛ Check source directory
  error("No source directory found") unless SRC_PATH.directory?
  # ☛ Check source files
  src_file_paths = Pathname.glob(SRC_PATH.join "*.rb")
  error("No source files have been found") if src_file_paths.empty?
  # ☛ Read build configuration.
  build_cfg = YAML.load_file(BUILD_CFG_PATH.to_s)

  info("Build configuration successfully loaded", success: true)

  build_cfg
end

def cleanup_bin
  error("Current fizzy binary is a directory.. WTF?") if BIN_PATH.directory?
  error("Old fizzy binary is a directory.. WTF?") if OLD_BIN_PATH.directory?
  OLD_BIN_PATH.delete if OLD_BIN_PATH.file?
  BIN_RB_PATH.delete  if BIN_RB_PATH.file?
  BIN_PATH.rename(OLD_BIN_PATH) if BIN_PATH.file?
end

def build_grammars(build_cfg)
  additional_sources = []

  build_cfg["grammars"].each do |grammar_name|
    info("Building grammar `#{grammar_name}`.", indent: 1)
    parser_src_path = GRAMMARS_PATH.join(grammar_name, "parser.y")
    lexer_path  = GRAMMARS_PATH.join(grammar_name, "lexer.rb")
    evaluator_path  = GRAMMARS_PATH.join(grammar_name, "evaluator.rb")
    parser_out_path = TMP_PATH.join("#{grammar_name}_parser.rb")

    status = system("racc " + (DEBUG ? "-g " : "") +
                    "   #{Shellwords.escape parser_src_path} " +
                    "-o #{Shellwords.escape parser_out_path}")
    error("Failed to run `racc` for `#{parser_src_path}`.") unless status
    additional_sources << lexer_path if lexer_path.file?
    additional_sources << evaluator_path if evaluator_path.file?
    additional_sources << parser_out_path
  end

  unless additional_sources.empty?
    grammar_start_index = build_cfg["sources"].find_index(GRAMMARS_SOURCE_NAME)
    error "Cannot find `grammar` in `sources` element in `build-cfg.yaml`." \
      unless grammar_start_index
    build_cfg["sources"].insert(grammar_start_index, *additional_sources)
    build_cfg["sources"].delete(GRAMMARS_SOURCE_NAME)
  end
end

desc "Build Fizzy"
task :build do
  build_cfg = load_build_cfg

  info("Build started")

  # ☞ Initial cleanup.
  cleanup_bin

  # ☞ Build grammars.
  build_grammars(build_cfg)

  # ☞ Write preamble.
  write_bin("HashBang", build_cfg["hashbang"], newlines: 2)
  write_bin("Header",   build_cfg["header"],   newlines: 1)

  # ☞ Write source files content.
  build_cfg["sources"].each do |src_file_name|
    src_file_path = Pathname.new(src_file_name)
    if src_file_path.absolute?
      src_file_name = src_file_path.basename(src_file_path.extname)
    else
      src_file_path = SRC_PATH.join("#{src_file_path}.rb")
    end
    src_file_name = src_file_name.to_s

    section_title = src_file_name.
      split("/").join(" → ").
      split("_").join(" ").
      split(/(\s+(?:\S+\s+)?)/).map { |e| e.capitalize }.join
    write_bin("Separator for section `#{src_file_name}`",
              "# ☞ #{section_title} ".ljust(80, "─"),
              newlines: [1, 2])
    write_bin("Content of file `#{src_file_name}`", src_file_path.read)
  end

  # ☞ Cleanup temporary files.
  build_cfg["sources"].
    select { |name|     name.to_s =~ /^#{TMP_PATH.to_s}/ }.
    each   { |tmp_file| tmp_file.delete                  }

  # ☞ Set executable permissions.
  BIN_PATH.chmod 0775

  # ☞ Link to a `.rb` file (mainly used for testing purposes).
  BIN_RB_PATH.make_symlink(BIN_PATH)

  info("Build successfully completed", success: true)
end

# ├────────────────────────────────────────────────────────────────────────────┤
# ├→ Task `package` ───────────────────────────────────────────────────────────┤

def runtimes_info
  build_cfg = load_build_cfg
  archs = build_cfg["traveling_ruby"]["archs"]
  traveling_vers = build_cfg["traveling_ruby"]["vers"]
  ruby_vers = build_cfg["traveling_ruby"]["ruby_vers"]

  runtimes_info = []
  archs.each do |os, archs|
    archs = [nil] if archs.nil?
    archs.each do |arch|
      name = runtime_name(traveling_vers, ruby_vers, os, arch)
      path = TMP_PATH.join("#{name}.tar.gz")
      runtimes_info << {
        traveling_vers: traveling_vers,
        ruby_vers: ruby_vers,
        os: os,
        arch: arch,
        name: name,
        path: path,
        rel_path: path.relative_path_from(ROOT_PATH)
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
  package_path = TMP_PATH.join("#{runtime}_tmp")
  package_lib_path = package_path.join("lib")
  package_app_path = package_lib_path.join("app")
  package_ruby_path = package_lib_path.join("ruby")
  package_vendor_path = package_lib_path.join("vendor")
  package_bundle_path = package_vendor_path.join(".bundle")
  package_launcher_path = package_path.join(BIN_PATH.basename)
  gemfile_path = ROOT_PATH.join("Gemfile")
  gemfile_lock_path = ROOT_PATH.join("Gemfile.lock")
  tmp_vendor_path = TMP_PATH.join("vendor")

  # Remove previous package.
  package_path.rmtree if package_path.exist?

  # Add the app.
  package_app_path.mkpath
  FileUtils.cp(BIN_PATH, package_app_path)

  # Add the ruby interpreter.
  package_ruby_path.mkpath
  sh "tar -xzf #{runtime_path} -C #{package_ruby_path}"

  # Build gems declared in Gemfile.
  FileUtils.cp(gemfile_path, TMP_PATH)
  FileUtils.cp(gemfile_lock_path, TMP_PATH)
  Bundler.with_clean_env do
    FileUtils.cd(TMP_PATH) do
      sh "BUNDLE_IGNORE_CONFIG=1 " +
         "bundle install " +
         "--path #{tmp_vendor_path} " +
         "--without development"
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
    "exec \"$SELFDIR/lib/ruby/bin/ruby\" -rbundler/setup \"$SELFDIR/lib/app/#{BIN_PATH.basename}\""
  ].join("\n"))

  if !ENV["DIR_ONLY"]
    # Create an archive containing the created runtime.
    FileUtils.cd(package_path) do
      sh "tar -czf #{dst_path} *"
    end
    package_path.rmtree if package_path.exist?
  end
end

# Download archives
runtimes_info.each do |runtime_info|
  file runtime_info[:rel_path] do
    download_runtime(runtime_info[:name], runtime_info[:path])
  end
end

task :package => [:build] + runtimes_info.map{|r_i| r_i[:rel_path]} do
  info("Packaging started")

  build_cfg = load_build_cfg

  runtimes_info.each do |runtime_info|
    dst_package_path = PKG_PATH.join([
      "fizzy-v#{build_cfg["version"]}",
      "ruby-v#{runtime_info[:ruby_vers]}",
      runtime_info[:os],
      runtime_info[:arch]
    ].compact.join("_") + ".tar.gz")
    create_package(runtime_info[:name], runtime_info[:path], dst_package_path)
  end

  info("Packaging successfully completed", success: true)
end

# ├────────────────────────────────────────────────────────────────────────────┤
# ├→ Task `run` ───────────────────────────────────────────────────────────────┤

task run: :build do |t, args|
  args = ARGV[1..-1]
  args.each { |a| task a.to_sym do ; end } # Prevent unknown task errors.

  cmd = BIN_PATH.to_s
  args = args.map { |arg| Shellwords.escape(arg) }.join(" ")

  if args.empty?
    exec(cmd)
  else
    exec(cmd, *args)
  end
end

# ├────────────────────────────────────────────────────────────────────────────┤
# ├→ Task `test` ──────────────────────────────────────────────────────────────┤

Rake::TestTask.new do |t|
  t.libs += [BUILD_PATH, TEST_PATH]
  t.test_files = FileList[TEST_PATH.join("test_*.rb")]
  t.verbose = true
end

task test: :build

# ├────────────────────────────────────────────────────────────────────────────┤
# ├→ Task `console` ───────────────────────────────────────────────────────────┤

task console: :build do
  system("irb -I . -r build/fizzy")
end

# └────────────────────────────────────────────────────────────────────────────┘

task default: :build
