require "spec_helper"

describe Fizzy::Template::Renderer do
  let(:data) { {a: "b", c: {d: "e", f: "g"}} }

  subject(:renderer) { described_class.new(data) }

  describe "#render" do
    let(:template) { "<%= a %> is <%= c[:d] %>" }
    let(:expected) { "b is e" }
    subject { renderer.render(template) }

    it { is_expected.to eq(expected) }
  end
end
