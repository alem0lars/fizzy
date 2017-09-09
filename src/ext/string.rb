#
# Extensions for class `String`.
#
class String
  include Fizzy::ANSIColors

  # ───────────────────────────────────────────────────────────────── Escapes ──

  #
  # Escapes the underlying object so that it can be safely used in a Bourne
  # shell commandline.
  #
  def shell_escape
    Shellwords.shellescape(self)
  end

  # ────────────────────────────────────────────────────────────── Formatting ──

  #
  # Turn the underlying string to a title.
  #
  def titleize!
    replace(split(/[_-]/).each(&:capitalize!).join(""))
  end

  #
  # Turn the underlying string to camel-case.
  #
  def camelize!
    titleize!
    replace(self[0, 1].downcase + self[1..-1])
  end

  #
  # Turn a camelized string into lowercase, separated with underscores.
  #
  def underscorize!
    replace(tr("-", "_"))
  end

  #
  # Turn a camelized string into lowercase, separated with dashes.
  #
  def dasherize!
    replace(tr("_", "-"))
  end

  #
  # Create a new string as a titleized version of the underlying string.
  #
  def titleize
    dup.tap(&:titleize!)
  end

  #
  # Create a new string as a camelized version of the underlying string.
  #
  def camelize
    dup.tap(&:camelize!)
  end

  #
  # Create a new string as a underscorized version of the underlying string.
  #
  def underscorize
    dup.tap(&:underscorize!)
  end

  #
  # Create a new string as a dasherized version of the underlying string.
  #
  def dasherize
    dup.tap(&:dasherize!)
  end

  #
  # Example environment variables contained inside the path.
  #
  def expand_variables
    vars_regexp = /\$([a-zA-Z_]+[a-zA-Z0-9_]*)|\$\{(.+)\}/
    gsub(vars_regexp) { ENV[Regexp.last_match(1) || Regexp.last_match(2)] }
  end
end
