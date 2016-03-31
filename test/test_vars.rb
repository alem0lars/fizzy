require "helper"

describe Fizzy::Vars do
  before do
    @vars_mock = Fizzy::Mocks::Vars.new({
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
  end

  describe "#get_var" do
    it "should retrieve available values" do
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
        @vars_mock.get_var(key).must_equal(expected)
      end
    end

    it "should retrieve `nil` for unavailable values" do
      @vars_mock.get_var("f00").must_be_nil
      @vars_mock.get_var("(f00|b4r)").must_be_nil
    end
  end
end
