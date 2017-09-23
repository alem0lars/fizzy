begin
  require "rufo"

  desc "Format Ruby code in current directory"
  task :lint, [:files_or_dirs] do |task, rake_args|
    Rufo::Command.run([$cfg[:paths][:src].to_s])
  end
rescue LoadError
  error("Rufo is not loaded: please `bundle install`")
end
