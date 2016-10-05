desc "Website-related tasks"
namespace :website do

  desc "Build the website"
  task :build do
    FileUtils.cd $cfg[:paths][:website] do
      sh "bower install"
      sh "bundle exec middleman build --verbose"
    end
  end

  desc "Preview the website"
  task :preview do
    FileUtils.cd $cfg[:paths][:website] do
      sh "bundle exec middleman serve"
    end
  end

end
