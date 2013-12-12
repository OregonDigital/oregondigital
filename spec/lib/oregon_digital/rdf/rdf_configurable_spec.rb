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
    before(:each) do
      DummyConfigurable.configure :base_uri => "http://example.org/base", :type => RDF::Literal, :rdf_label => RDF::DC.title
    end

    it 'should set a base uri' do
      expect(DummyConfigurable.base_uri).to eq "http://example.org/base"
    end

    it 'should set an rdf_label' do
      expect(DummyConfigurable.rdf_label).to eq RDF::DC.title
    end

    it 'should set a type' do
      expect(DummyConfigurable.type).to eq RDF::Literal
    end
  end
end
