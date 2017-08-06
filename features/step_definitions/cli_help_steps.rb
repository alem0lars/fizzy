Given(/^fizzy commandline interface$/) do
  commands = Fizzy::CLI::Command.available.collect(&:new)
  commands.each { |command| Fizzy::CLI::Main.instance.add_subcommand(command) }
  @args = []
  @run =
    lambda do
      Fizzy::CLI::Main.instance.run if Fizzy::CLI::Main.instance.parse(@args)
    end
end

When(/^I provide '(\S+)' as first argument$/) do |command_name|
  @command_name = command_name
  @args << @command_name
end

When(/^I provide a valid command name as second argument$/) do
  @sample_command = Fizzy::CLI::Command.available.first.new
  @args += ["-C", @sample_command.name]
end

When(/^I provide an invalid command name as second argument$/) do
  @args += ["-C", "foo-bar"]
end

Then(/^I should see the help for that command.+$/) do
  expected  = Fizzy::ANSIColors.colorize(@sample_command.help)
  expected += "\n"
  expect { @run.call }.to output(expected).to_stdout
end

Then(/^I should see an invalid command error message$/) do
  puts @args
  @run.call
  #expect { @run.call }.not_to output(@sample_command.tell_help).to_stdout
end
