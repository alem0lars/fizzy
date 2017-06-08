class Symbol

  # Escapes the underlying object so that it can be safely used in a Bourne
  # shell commandline.
  #
  def shell_escape
    self.to_s.shell_escape.to_sym
  end

  # Create a new symbol as a titleized version of the underlying symbol.
  #
  def titleize
    self.to_s.titleize.to_sym
  end

  # Create a new symbol as a camelized version of the underlying symbol.
  #
  def camelize
    self.to_s.camelize.to_sym
  end

  # Create a new symbol as a underscorized version of the underlying symbol.
  #
  def underscorize
    self.to_s.underscorize.to_sym
  end

  # Create a new symbol as a dasherized version of the underlying symbol.
  #
  def dasherize
    self.to_s.dasherize.to_sym
  end

end
