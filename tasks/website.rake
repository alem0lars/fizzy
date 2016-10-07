desc "Website-related tasks"
namespace :website do

  desc "Build the website"
  task :build do
    FileUtils.cd $cfg[:paths][:website] do
      sh "bower install", verbose: :false
      sh "bundle exec middleman build --verbose", verbose: :false
    end
  end
  task build: :build

  desc "Preview the website"
  task :preview do
    FileUtils.cd $cfg[:paths][:website] do
      sh "bundle exec middleman serve", verbose: :false
    end
  end

end
