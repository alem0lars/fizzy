# Entry point.
if $PROGRAM_NAME == __FILE__
  cli = Fizzy::CLI.create
  cli.run if cli.parse(ARGV)
end
