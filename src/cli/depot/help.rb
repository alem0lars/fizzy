#
# Fizzy command to show configuration details.
#
class Fizzy::CLI::Help < Fizzy::CLI::Command
  def initialize
    super("Show command help.",
          spec: {
            command_name: {
              desc: "The command name to show help for",
              abbrev: "C",
              type: Fizzy::CLI::Command.available.map(&:command_name),
              required: true
            }
          })
  end

  def run
    Fizzy::CLI::Main.instance.tell_help(options[:command_name])
  end
end
