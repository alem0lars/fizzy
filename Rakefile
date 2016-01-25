# Requires ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require "pathname"
require "yaml"

# Configuration ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ROOT_PATH = Pathname.new(File.dirname(__FILE__))
BUILD_PATH = ROOT_PATH.join("build")
SRC_PATH = ROOT_PATH.join("src")
OLD_BIN_PATH = BUILD_PATH.join("fizzy-old")
BIN_PATH = BUILD_PATH.join("fizzy")
BUILD_CFG_PATH = ROOT_PATH.join("build-cfg.yaml")

# Utils ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def info(msg, indent: 0, success: false)
  puts(("\t" * indent) + "☞ " + "\e[#{success ? 32 : 34}m#{msg}\e[0m")
end

def error(msg)
  puts("\e[31m☠ Error: #{msg}\e[0m")
  exit(-1)
end

# Task `build` ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def write_bin(title, content, newlines: [0, 0], mode: "a")
  BIN_PATH.open(mode) do |bin_file|
    info("Filling binary with: #{title}", indent: 1) if title && !title.empty?
    content = "" if content.nil?
    if newlines.is_a?(Array) && newlines.length == 2
      content = ("\n" * newlines.first) + content + ("\n" * newlines.last)
    elsif newlines.is_a?(Fixnum)
      content = content + ("\n" * newlines)
    else
      error("Invalid argument `newlines`: expected to be a 2-ple or number")
    end
    bin_file.write(content)
  end
end

def prepare_build
  info("Preparing for build")

  # ☛ Check build directory
  error("The build directory `#{BUILD_PATH}` is reserved") if BUILD_PATH.file?
  BUILD_PATH.mkdir unless BUILD_PATH.directory?
  # ☛ Check current/old fizzy binaries
  error("Current fizzy binary is a directory.. WTF?") if BIN_PATH.directory?
  error("Old fizzy binary is a directory.. WTF?") if OLD_BIN_PATH.directory?
  OLD_BIN_PATH.delete if OLD_BIN_PATH.file?
  BIN_PATH.rename(OLD_BIN_PATH) if BIN_PATH.file?
  # ☛ Check source directory
  error("No source directory found") unless SRC_PATH.directory?
  # ☛ Check source files
  src_file_paths = Pathname.glob(SRC_PATH.join("*.rb"))
  error("No source files have been found") if src_file_paths.empty?
  # ☛ Read build configuration
  build_cfg = YAML.load_file(BUILD_CFG_PATH.to_s)

  info("Build successfully prepared", success: true)
  return build_cfg
end

desc "Build Fizzy"
task :build do
  build_cfg = prepare_build

  info("Build started")

  # ☛ Write preamble
  write_bin("HashBang", build_cfg["hashbang"], newlines: 2)
  write_bin("Header", build_cfg["header"], newlines: 1)

  # ☛ Write source files content
  build_cfg['files'].each do |src_file_name|
    src_file_path = SRC_PATH.join("#{src_file_name}.rb")

    section_title = src_file_name.
      split("/").join(" → ").
      split("_").join(" ").
      split(/(\s+(?:\S+\s+)?)/).map { |e| e.capitalize }.join
    write_bin("Separator for section `#{src_file_name}`",
              "# ☞ #{section_title} ".ljust(80, "━"),
              newlines: [1, 2])
    write_bin("Content of file `#{src_file_name}`", src_file_path.read)
  end

  # ☛ Set executable permissions.
  BIN_PATH.chmod(0775)

  info("Build successfully completed", success: true)
end

# Task `run` ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

task :run => :build do |t, args|
  args = ARGV[1..-1]
  args.each { |a| task a.to_sym do ; end } # Prevent unknown task errors.

  cmd = BIN_PATH.to_s
  args = args.map { |arg| Shellwords.escape(arg) }.join(" ")

  if args.empty?
    exec cmd
  else
    exec cmd, *args
  end
end

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

task :default => :build
