#
# Entry point.
#

if $PROGRAM_NAME == __FILE__
  if RUBY_VERSION < Fizzy::CFG.minimum_ruby_version
    error "Invalid ruby version detected."
  end

  commands = Fizzy::CLI::Command.available.collect(&:new)
  commands.each { |command| Fizzy::CLI::Main.instance.add_subcommand(command) }
  Fizzy::CLI::Main.instance.run if Fizzy::CLI::Main.instance.parse(ARGV)
end
