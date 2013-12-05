require "spec_helper"
describe OregonDigital::RDF::RdfConfigurable do
  before(:each) do
    class DummyConfigurable
      extend OregonDigital::RDF::RdfConfigurable
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyConfigurable") if Object
  end

  describe '#configure' do
    it 'should set a base uri'
    it 'should set an rdf_label'
    it 'should set a type'
  end

  describe '#rdf_label' do
    it 'should have good defaults if a label is not set'
  end

  describe '#base_uri' do
    it 'should be the default uri base for new objects'
  end

  describe '#type' do
    it 'should return its own type'

  end

end
