class Pathname

  # Escapes the string representation of the underlying object,
  # so that it can be safely used in a Bourne shell commandline.
  #
  def shell_escape
    Shellwords.shellescape(self)
  end

  def expand_variables
    Pathname.new(self.to_s.expand_variables)
  end

end
