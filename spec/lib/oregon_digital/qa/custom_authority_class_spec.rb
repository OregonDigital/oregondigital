require 'spec_helper'

describe OregonDigital::Qa::CustomAuthorityClass do
  before(:each) do
    # Simulate *exactly* how we inject into the QA class
    class DummyClass
      def authority_class
        raise Exception.new("This shouldn't be hit")
      end
    end

    DummyClass.send(:prepend, OregonDigital::Qa::CustomAuthorityClass)

    @instance = DummyClass.new

    # Set up various patterns for testing priority
    OregonDigital::Qa::CustomAuthorityClass.stub(:qa_class_patterns => ["First::%s", "Second::%s"])
  end

  after(:each) do
    Object.send(:remove_const, "DummyClass")
  end

  describe "#authority_class" do
    it "should properly prioritize patterns" do
      stub_const("Second::One", double("Second::One"))
      @instance.stub(:params => {vocab: "One"})
      expect(@instance.send(:authority_class)).to eql("Second::One")

      stub_const("First::One", double("First::One"))
      expect(@instance.send(:authority_class)).to eql("First::One")
    end

    it "should allow deep namespaces" do
      stub_const("Second::One::More", double("Second::One::More"))
      @instance.stub(:params => {vocab: "One::More"})
      expect(@instance.send(:authority_class)).to eql("Second::One::More")
    end

    it "should fallback to the default behavior if patterns don't match" do
      @instance.stub(:params => {vocab: "One"})
      expect {
        @instance.send(:authority_class)
      }.to raise_error(Exception, "This shouldn't be hit")
    end
  end
end
