require "spec_helper"
describe OregonDigital::RdfConfigurable do
  before(:each) do
    class DummyConfigurable
      extend OregonDigital::RdfConfigurable
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyConfigurable") if Object
  end
  describe '#property' do
    it 'should set a property' do
      DummyConfigurable.property :title, :predicate => RDF::DC.title
      expect(DummyConfigurable.properties).to include :title
    end
    it 'should set index behaviors' do
      DummyConfigurable.property :title, :predicate => RDF::DC.title do |index|
        index.as :facetable, :searchable
      end
      expect(DummyConfigurable.properties[:title][:behaviors]).to eq [:facetable, :searchable]
    end
    it 'should set class name' do
      DummyConfigurable.property :title, :predicate => RDF::DC.title, :class_name => RDF::Literal
      expect(DummyConfigurable.properties[:title][:class_name]).to eq RDF::Literal
    end
  end

end
