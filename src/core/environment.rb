# Utilities to retrieve informations about the host environment & system.
#
module Fizzy::Environment
  include Fizzy::IO

  #
  # Find an executable called `name` in the `$PATH`.
  # Note: `name` can also be a path pointing to the executable.
  #
  def which?(_name)
    exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
    ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end
    nil
  end

  #
  # Return the environment variable matching the provided `name`.
  #
  def get_env(name, default: nil)
    ENV[name.to_s] || default
  end

  # Same of `get_env`, but raise an error if the environment variable hasn't
  # been found or is `nil`.
  #
  def get_env!(name)
    value = get_env(name)
    error("Undefined environment variable: `#{name}`.") if value.nil?
    value
  end

  # Check if the underlying operating system is MacOSX.
  #
  def osx?
    Fizzy::CFG.os == :osx
  end

  # Check if the underlying operating system is GNU/Linux.
  #
  def linux?
    Fizzy::CFG.os == :linux
  end

  # Check if the underlying operating system is Windows.
  #
  def windows?
    Fizzy::CFG.os == :windows
  end

  # Execute a function, based on the underlying operating system.
  #
  def case_os(osx: nil, linux: nil, windows: nil)
    if osx?
      osx.respond_to?(:call) ? osx.call : osx
    elsif linux?
      linux.respond_to?(:call) ? linux.call : linux
    elsif windows?
      windows.respond_to?(:call) ? windows.call : windows
    else
      error("Unrecognized operating system.")
    end
  end

  def xdg_config_home(name)
    Pathname.new(get_env(:XDG_CONFIG_HOME) || "~/.config")
            .expand_variables
            .expand_path
            .join(name.to_s)
  end
end
