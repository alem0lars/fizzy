namespace :doc do
  YARD::Rake::YardocTask.new do |t|
    t.name = "generate"

    t.files = FileList["src/**/*.rb", "-", *Dir["*.md"]]

    t.options += ["--protected"]

    t.options += ["--title", "fizzy documentation"]

    t.options += ["--markup",          $cfg[:api_doc][:markup][:name]]
    t.options += ["--markup-provider", $cfg[:api_doc][:markup][:provider]]
    t.options += ["--main",            $cfg[:api_doc][:main]]

    t.options += ["--output-dir", "website/source/docs/api"]
  end
  task generate: :build

  desc "Run a local documentation server"
  task serve: "doc:generate" do
    sh "yard server --reload"
  end
end
