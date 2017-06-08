begin
  require "rubocop/rake_task"

  RuboCop::RakeTask.new :lint
  task lint: :build
rescue LoadError
  error("Rubocop is not loaded: please `bundle install`")
end
