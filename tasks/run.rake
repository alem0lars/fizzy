desc "Run fizzy with a provided command"
task run: :build do |t, args|
  cmd = $cfg[:paths][:bin].to_s
  cmd_env_var_name = "CMD"
  args = ENV[cmd_env_var_name] || error("Invalid command: not provided")

  if args.empty?
    exec(cmd)
  else
    exec(cmd, *args)
  end
end
