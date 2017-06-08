desc "Start a repl with fizzy preloaded"
task repl: :build do
  sh "irb -I . -r irbtools -r build/fizzy"
end

namespace :docker do
  desc "Start a repl with fizzy preloaded inside the docker container"
  task repl: :prepare do
    docker_run "fizzy", "rake repl"
  end
end
