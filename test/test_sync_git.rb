require "helper"

describe Fizzy::Sync::Git do

  include Fizzy::TestUtils::Docker

  it "should work" do
    skip unless in_docker?
  end
end
