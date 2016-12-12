class String

  # Escapes the underlying object so that it can be safely used in a Bourne
  # shell commandline.
  #
  def shell_escape
    Shellwords.shellescape(self)
  end

  # Turn the underlying string to a title.
  #
  def titleize!
    self.replace(self.split(/[_-]/).each { |s| s.capitalize! }.join(""))
  end

  # Turn the underlying string to camel-case.
  #
  def camelize!
    self.titleize!
    self.replace(self[0, 1].downcase + self[1..-1])
  end

  # Turn a camelized string into lowercase, separated with underscores.
  #
  def underscorize!
    self.replace(self.scan(/[A-Z][a-z]*/).join("_").downcase)
  end

  # Turn a camelized string into lowercase, separated with dashes.
  #
  def dasherize!
    self.replace(self.scan(/[A-Z][a-z]*/).join("-").downcase)
  end

  # Create a new string as a titleized version of the underlying string.
  #
  def titleize
    dup.tap(&:titleize!)
  end

  # Create a new string as a camelized version of the underlying string.
  #
  def camelize
    dup.tap(&:camelize!)
  end

  # Create a new string as a underscorized version of the underlying string.
  #
  def underscorize
    dup.tap(&:underscorize!)
  end

  # Create a new string as a dasherized version of the underlying string.
  #
  def dasherize
    dup.tap(&:dasherize!)
  end

end
