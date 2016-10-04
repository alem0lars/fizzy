module Fizzy::TestUtils::Testable
  def doit
    pm = self.class.protected_instance_methods

    before(:each) do
      self.class.send(:public, *pm)
    end

    after(:each) do
      self.class.send(:protected, *pm)
    end
  end
end