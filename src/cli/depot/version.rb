#
# Fizzy command to show fizzy version.
#
class Fizzy::CLI::Help < Fizzy::CLI::Command
  def initialize
    super("Show fizzy version.")
  end

  def run
    info("fizzy version", "{m{#{Fizzy::CFG.version}}}")
    info("ruby version", "{m{ruby #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}}}")
  end
end
