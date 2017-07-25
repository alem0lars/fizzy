RSpec.configure do |config|
  # Prevent that `SystemExit` won't be cached.
  config.around(:example) do |example|
    begin
      example.run
    rescue SystemExit
      raise "Got SystemExit!"
    end
  end
end
