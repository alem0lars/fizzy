begin
  require "rubocop/rake_task"

  RuboCop::RakeTask.new("lint")
rescue LoadError
  error("Rubocop is not loaded: please `bundle install`")
end
