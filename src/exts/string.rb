#
# Safely encode templates before evaluating them.
#
# XXX Needed because of thor.
#
# TODO When thor dependency is removed, remove this shitty monkey patch!
#
class IO #:nodoc:
  class << self
    def binread(file, *args)
      raise ArgumentError, "wrong number of arguments (#{1 + args.size} for 1..3)" unless args.size < 3
      File.open(file, "rb") do |f|
        f.read(*args).safe_encode
      end
    end
  end
end

class String

  include Fizzy::ANSIColors

  # ───────────────────────────────────────────────────────────────── Escapes ──

  # Escapes the underlying object so that it can be safely used in a Bourne
  # shell commandline.
  #
  def shell_escape
    Shellwords.shellescape(self)
  end

  # ──────────────────────────────────────────────────────────────── Encoding ──

  def safe_encode
    self.encode("utf-8", invalid: :replace, undef: :replace, replace: "_")
  end

  # ────────────────────────────────────────────────────────────── Formatting ──

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

  def expand_variables
    vars_regexp = /\$([a-zA-Z_]+[a-zA-Z0-9_]*)|\$\{(.+)\}/
    self.gsub(vars_regexp) { ENV[$1||$2] }
  end

end
