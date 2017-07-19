require "spec_helper"


describe Fizzy::CFG do

  subject { described_class.version }

  it { is_expected.to match(/[0-9]+\.[0-9]+\.[0-9]+/) }

end
