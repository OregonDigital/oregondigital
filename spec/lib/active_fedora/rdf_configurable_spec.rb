require "spec_helper"
describe ActiveFedora::Rdf::Configurable do
  before(:each) do
    class DummyConfigurable
      extend ActiveFedora::Rdf::Configurable
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyConfigurable") if Object
  end

  describe '#configure' do
    before(:each) do
      DummyConfigurable.configure :base_uri => "http://example.org/base", :type => RDF.Class, :rdf_label => RDF::DC.title
    end

    it 'should set a base uri' do
      expect(DummyConfigurable.base_uri).to eq "http://example.org/base"
    end

    it 'should set an rdf_label' do
      expect(DummyConfigurable.rdf_label).to eq RDF::DC.title
    end

    it 'should set a type' do
      expect(DummyConfigurable.type).to eq RDF.Class
    end
  end

  describe '#rdf_type' do
    it "should set the type the old way" do
      expect(DummyConfigurable).to receive(:configure).with(:type => RDF.Class).and_call_original
      DummyConfigurable.rdf_type(RDF.Class)
      expect(DummyConfigurable.type).to eq RDF.Class
    end
  end
end
