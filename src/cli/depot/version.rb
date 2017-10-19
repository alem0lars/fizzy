#
# Fizzy command to show fizzy version.
#
class Fizzy::CLI::Version < Fizzy::CLI::Command
  def initialize
    super("Show fizzy version.")
  end

  def run
    info "fizzy version", "#{✏ Fizzy::CFG.version}"
    info "ruby version", "#{✏ "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"}"
  end
end
