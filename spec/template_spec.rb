require "spec_helper"

describe Fizzy::Template::Renderer do
  let(:data) { {a: "gentoo", c: {d: "pwns", f: "sucks"}} }

  subject(:renderer) { described_class.new(data) }

  describe "#render" do
    let(:template) { "<%= a %> <%= c[:d] %>!" }
    let(:expected) { "gentoo pwns!" }
    subject { renderer.render(template) }

    it { is_expected.to eq(expected) }
  end
end
