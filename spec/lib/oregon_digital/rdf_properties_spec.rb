require "spec_helper"
describe OregonDigital::RdfProperties do
  before(:each) do
    class DummyProperties
      extend OregonDigital::RdfProperties
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyProperties") if Object
  end

  describe '#property' do
    it 'should set a property' do
      DummyProperties.property :title, :predicate => RDF::DC.title
      expect(DummyProperties.properties).to include :title
    end
    it 'should set index behaviors' do
      DummyProperties.property :title, :predicate => RDF::DC.title do |index|
        index.as :facetable, :searchable
      end
      expect(DummyProperties.properties[:title][:behaviors]).to eq [:facetable, :searchable]
    end
    it 'should set class name' do
      DummyProperties.property :title, :predicate => RDF::DC.title, :class_name => RDF::Literal
      expect(DummyProperties.properties[:title][:class_name]).to eq RDF::Literal
    end
  end
end
