class Fizzy::Filter::Base
  include Fizzy::IO

  attr_reader :name, :desc

  def initialize(name, desc)
    @name = name
    @desc = desc
  end

  abstract_method :match?
  abstract_method :apply
end
