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

  describe '#configure' do
    it 'should set a base uri'
    it 'should set an rdf_label'
    it 'should set a type'
  end

  describe '#rdf_label' do
    it 'should have good defaults if a label is not set'
    it 'should return the values for the configured label'
  end

  describe '#base_uri' do
    it 'should be the default uri base for new objects'
  end

  describe '#type' do
    it 'should return its own type'
    it 'should be the type in the graph'
  end

end
