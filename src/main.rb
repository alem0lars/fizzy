# Entry point.
if $PROGRAM_NAME == __FILE__
  Fizzy::CLI::Main.instance.run if Fizzy::CLI::Main.instance.parse(ARGV)
end
