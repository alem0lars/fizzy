namespace :doc do
  YARD::Rake::YardocTask.new do |t|
    t.name = "generate"
    # TODO
    # t.files = ["src/**/*.rb", "-", "CHANGELOG.md"]#] + Dir["*.md"].reject{|e| e == $cfg[:api_doc][:main]}
    # t.options = %W[
    #   --markup-provider #{$cfg[:api_doc][:markup][:provider]}
    #   --markup #{$cfg[:api_doc][:markup][:name]}
    #   --main #{$cfg[:api_doc][:main]}
    # ]
  end

  desc "Run a local documentation server"
  task server: "doc:generate" do
    sh "yard server --reload"
  end
end
