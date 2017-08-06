begin
  require "cucumber"
  require "cucumber/rake/task"

  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = "features --format pretty"
  end
  task cucumber: :build
rescue LoadError
  error("Cucumber is not loaded: please `bundle install`")
end

begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts  = ["--require spec_helper"]
    t.pattern     = "spec/**/*_spec.rb"
  end
  task spec: :build
rescue LoadError
  error("RSpec is not loaded: please `bundle install`")
end

namespace :docker do
  desc "Test fizzy inside the docker container"
  task spec: :prepare do
    ENV["DOCKER_SILENT_BUILD"] = "true"
    docker_run("fizzy", "rake spec")
  end
end
