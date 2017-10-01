#
# Extensions for class `Pathname`.
#
class Pathname

  #
  # Escapes the string representation of the underlying object,
  # so that it can be safely used in a Bourne shell commandline.
  #
  def shell_escape
    Shellwords.shellescape(self)
  end

  #
  # Example environment variables contained inside the path.
  #
  def expand_variables
    Pathname.new(to_s.expand_variables)
  end

end
