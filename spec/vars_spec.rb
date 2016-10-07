require "spec_helper"


describe Fizzy::Vars do

  let(:vars_mock) {
    Fizzy::Mocks::Vars.new({
      "foo"    => "bar",
      "notfoo" => "notbar",
      "qwe"    => "rty",
      "vip"    => {
        "pluto"    => "male",
        "paperino" => "male",
        "minnie"   => "female",
        "frozen"   => %w(anna elsa),
        "others"   => {
          "dragon" => "ball",
          "naruto" => "shit"
        }
      }
    })
  }

  describe "#get_var" do

    context "when an available variable" do
      { "foo"                        => "bar",
        "(foo|qwe)"                  => %w(bar rty),
        "(foo|ewq)"                  => "bar",
        "(not)foo"                   => "notbar",
        "vip.frozen"                 => %w(anna elsa),
        "vip.(pluto|minnie)"         => %w(male female),
        "vip.(pluto|paperino)"       => %w(male male),
        "vip.(pluto|cingli)"         => "male",
        "vip.(others|cingli).dragon" => "ball"
      }.each do |key, expected|
        context "`#{key} is retrieved" do
          subject { vars_mock.get_var(key) }
          it { is_expected.to eq(expected) }
        end
      end
    end

    context "when a unavailable variable" do
      [ "f00",
        "(f00|b4r)"
      ].each do |key|
        context "`#{key} is retrieved" do
          subject { vars_mock.get_var(key) }
          it { is_expected.to be_nil }
        end
      end
    end

  end
end
