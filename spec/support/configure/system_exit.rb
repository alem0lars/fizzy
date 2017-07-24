RSpec.configure do |config|
  # Prevent that `SystemExit` won't be cached.
  config.around(:example) do |ex|
    begin
      ex.run
    rescue SystemExit
      raise "Got SystemExit!"
    end
  end
end
