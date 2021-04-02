require 'spec_helper'
describe Hyrax::Migrator::MetadataProfiler do
  include Hyrax::Migrator::MetadataProfiler
  describe 'assemble_derivatives_info' do
    let(:item) { double }
    let(:dstream1) { double }
    let(:dstream2) { double }
    let(:datastreams) {
      {
      'DC' => dstream1,
      'thumbnail' => dstream2
      }
    }
    
    before do
      allow(item).to receive(:datastreams).and_return(datastreams)
      allow(dstream1).to receive(:controlGroup).and_return('X')
      allow(dstream2).to receive(:controlGroup).and_return('E')
    end

    it 'returns a list of the derivatives' do
      expect(assemble_derivatives_info(item.datastreams)).to include('has_thumbnail: true')
    end
  end

  describe 'query_graph' do
    let(:item) { double }
    let(:descMetadata) { double }
    let(:subject) { RDF::URI('http://oregondigital.org/resource/abcde1234') }
    let(:predicate) { RDF::URI('http://opaquenamespace.org/ns/set') }
    let(:object) { RDF::URI('http://oregondigital.org/resource/oregondigital:famous-donuts') }
    let(:graph) do
      g = RDF::Graph.new
      g << RDF::Statement.new(subject, predicate, object)
      g
    end

    before do
      allow(item).to receive(:descMetadata).and_return(descMetadata)
      allow(descMetadata).to receive(:graph).and_return(graph)
    end

    it 'returns a short pid' do
      expect(query_graph(item, 'set')).to eq(['famous-donuts'])
    end
  end
 
  describe 'assemble_field' do
    let(:crosswalk_service) { double }
    let(:crosswalk_hash) do
      [{ property: "title", predicate: "http://purl.org/dc/terms/title" , multiple: true, function: nil },
       { property: "creator_attributes", predicate: "purl.org/dc/elements/1.1/creator", multiple: true, function: "attributes_data" },
       { property: "firstLine", predicate: "http://opaquenamespace.org/ns/sheetmusic_firstLine", multiple: false, function: nil }]
    end

    before do
      allow(Hyrax::Migrator::CrosswalkMetadata).to receive(:new).and_return(crosswalk_service)
      allow(crosswalk_service).to receive(:crosswalk_hash).and_return(crosswalk_hash)
    end

    context 'when the value is a string' do
      let(:field) { 'title' }
      let(:val) { ['Maple Bar'] }
      let(:report) { "  title:\n  - \"Maple Bar\"\n" }

      it 'returns the formatted string' do
        expect(assemble_field(field, val)).to eq(report)
      end
    end

    context 'when the value is controlled' do
      let(:field) { 'creator' }
      let(:vals) { [val] }
      let(:val) { double }
      let(:rdf_subject) { RDF::URI('http://dbpedia.org/resource/dunkin-donuts') }
      let(:report) { "  creator:\n  - \"http://dbpedia.org/resource/dunkin-donuts\"\n" }

      before do
        allow(val).to receive(:respond_to?).and_return(true)
        allow(val).to receive(:rdf_subject).and_return(rdf_subject)
      end

      it 'returns the subject as a formatted string' do
        expect(assemble_field(field, vals)).to eq(report)
      end
    end

    context 'when the field will not be an array on OD2' do
      let(:field) { 'firstLine' }
      let(:vals) { ['Aardvark a mile for one of your smiles'] }
      let(:report) { "  firstLine: \"Aardvark a mile for one of your smiles\"\n" }

      it 'returns the formatted string' do
        expect(assemble_field(field, vals)).to eq(report)
      end
    end
  end
end
