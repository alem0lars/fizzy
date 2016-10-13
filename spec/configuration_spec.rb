require "spec_helper"

# TODO: Use shared examples (if it makes sense)
describe Fizzy::CFG.version do

  it "is compliant with the semver format" do
    expect(Fizzy::CFG.version).to match(/[0-9]+\.[0-9]+\.[0-9]+/)
  end

end
