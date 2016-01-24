# Host environment / system

module Fizzy::Utils

  #
  # Return the environment variable matching the provided `name`.
  #
  def get_env(name)
    ENV[name.to_s]
  end

  #
  # Same of `get_env`, but raise an error if the environment variable hasn't
  # been found or is `nil`.
  #
  def get_env!(name)
    get_env(name) || error("Undefined environment variable: `#{name}`.")
  end

  #
  # Check if the underlying operating system is MacOSX.
  #
  def is_osx?
    Fizzy::CFG.os == :osx
  end

  #
  # Check if the underlying operating system is GNU/Linux.
  #
  def is_linux?
    Fizzy::CFG.os == :linux
  end

end
