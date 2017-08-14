#
<<<<<<< HEAD
<<<<<<< HEAD:src/ext/string.rb
# Extensions for class `String`.
#
=======
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

>>>>>>> v2.3.3:src/exts/string.rb
=======
# Extensions for class `String`.
#
>>>>>>> 67d3ef399ae81adc693fa05dc5ed17bec058f861
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

<<<<<<< HEAD
  # ──────────────────────────────────────────────────────────────── Encoding ──

  def safe_encode
    self.encode("utf-8", invalid: :replace, undef: :replace, replace: "_")
  end

=======
>>>>>>> 67d3ef399ae81adc693fa05dc5ed17bec058f861
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
