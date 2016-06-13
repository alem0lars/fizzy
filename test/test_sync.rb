require "helper"

describe Fizzy::Sync do

  before do
    @local_dir_path = "foo"
    @remote_url = "github.com/cingli"
  end

  it "asdasd" do
    puts Fizzy::Sync.available_synchronizers(@local_dir_path, @remote_url)
  end

end
