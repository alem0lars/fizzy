#
# Entry point.
#

if $PROGRAM_NAME == __FILE__
  commands = Fizzy::CLI::Command.available.collect(&:new)
  commands.each { |command| Fizzy::CLI::Main.instance.add_subcommand(command) }
  Fizzy::CLI::Main.instance.run if Fizzy::CLI::Main.instance.parse(ARGV)
end
