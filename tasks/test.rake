begin
  require "cucumber"
  require "cucumber/rake/task"

  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = "-r spec/features --format pretty"
  end
rescue LoadError
  error("Cucumber is not loaded: please `bundle install`")
end

begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:test) do |t|
    t.rspec_opts  = ["--require spec_helper"]
    t.pattern     = "spec/#{ENV["S"] || "*"}_spec.rb"
  end
  task test: :build
rescue LoadError
  error("RSpec is not loaded: please `bundle install`")
end

namespace :docker do
  desc "Test fizzy inside the docker container"
  task test: :prepare do
    docker_run "fizzy", "rake test"
  end
end
