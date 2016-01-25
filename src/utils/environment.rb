# Utilities to retrieve informations about the host environment & system.
#
module Fizzy::Environment

  # Return the environment variable matching the provided `name`.
  #
  def get_env(name, default: nil)
    ENV[name.to_s] || default
  end

  # Same of `get_env`, but raise an error if the environment variable hasn't
  # been found or is `nil`.
  #
  def get_env!(name)
    get_env(name) || error("Undefined environment variable: `#{name}`.")
  end

  # Check if the underlying operating system is MacOSX.
  #
  def is_osx?
    Fizzy::CFG.os == :osx
  end

  # Check if the underlying operating system is GNU/Linux.
  #
  def is_linux?
    Fizzy::CFG.os == :linux
  end

end