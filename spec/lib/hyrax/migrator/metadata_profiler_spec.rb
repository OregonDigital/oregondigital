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
    let(:subject) { RDF::URI('http://oregondigital.org/resource/abcde1234') }
    let(:predicate) { RDF::URI('http://opaquenamespace.org/ns/set') }
    let(:object) { RDF::URI('http://oregondigital.org/resource/oregondigital:famous-donuts') }
    let(:graph) do
      g = RDF::Graph.new
      g << RDF::Statement.new(subject, predicate, object)
      g
    end

    it 'returns a short pid' do
      expect(query_graph(graph, 'set')).to eq(['famous-donuts'])
    end
  end
 
  describe 'assemble_contents' do
    let(:descMetadata) { double }
    let(:subject) { RDF::URI('http://oregondigital.org/resource/abcde1234') }
    let(:predicate) { RDF::URI('http://opaquenamespace.org/ns/contents') }
    let(:pid1) { 'fghij2323' }
    let(:pid2) { 'klmno4545' }
    let(:object1) { RDF::URI("http://oregondigital.org/resource/oregondigital:#{pid1}") }
    let(:object2) { RDF::URI("http://oregondigital.org/resource/oregondigital:#{pid2}") }
    let(:graph) do
      g = RDF::Graph.new
      g << RDF::Statement.new(subject, predicate, object1)
      g << RDF::Statement.new(subject, predicate, object2)
      g
    end
    context 'when the work is a cpd' do
      it 'lists the children on the profile' do
        parsed = YAML::parse(assemble_contents(graph))
        expect(parsed.to_ruby["contents"]).to eq [pid1, pid2]
      end
    end
  end

  describe 'assemble_fields' do
    let(:property_hash) { { location: 'http://purl.org/dc/terms/spatial' } }
    let(:crosswalk_service) { double }
    let(:crosswalk_hash) do
      [{ property: "location", predicate: "http://purl.org/dc/terms/spatial" , multiple: true, function: nil }]
    end

    let(:obj) { RDF::URI('http://sws.geonames/123456/') }
    let(:graph) do
      g = RDF::Graph.new
      subj = RDF::URI('http://oregondigital.org/resource/oregondigital:abcde1234')
      pred = RDF::URI('http://purl.org/dc/terms/spatial')
      g << RDF::Statement(subj, pred, obj)
      g
    end

    before do
      allow(Hyrax::Migrator::CrosswalkMetadata).to receive(:new).and_return(crosswalk_service)
      allow(crosswalk_service).to receive(:crosswalk_hash).and_return(crosswalk_hash)
      allow(Hyrax::Migrator::MetadataProfiler).to receive(:property_hash).and_return(property_hash)
    end

    it 'assembles string of fields' do
      expect(assemble_fields(graph)).to eq("  location:\n  - \"http://sws.geonames/123456/\"\n")
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

      it 'returns the formatted string' do
        parsed = YAML::parse(assemble_field(field, val))
        expect(parsed.to_ruby["title"]).to eq ["Maple Bar"]
      end
    end

    context 'when the value is controlled' do
      let(:field) { 'creator' }
      let(:vals) { [val] }
      let(:val) { double }
      let(:rdf_subject) { RDF::URI('http://dbpedia.org/resource/dunkin-donuts') }

      before do
        allow(val).to receive(:respond_to?).and_return(true)
        allow(val).to receive(:rdf_subject).and_return(rdf_subject)
      end

      it 'returns the subject as a formatted string' do
        parsed = YAML::parse(assemble_field(field, vals))
        expect(parsed.to_ruby['creator']).to eq [rdf_subject.to_s]
      end
    end

    context 'when the field will not be an array on OD2' do
      let(:field) { 'firstLine' }
      let(:vals) { ['Aardvark a mile for one of your smiles'] }

      it 'returns the formatted string' do
        parsed = YAML::parse(assemble_field(field, vals))
        expect(parsed.to_ruby['firstLine']).to eq vals.first
      end
    end
  end

  describe 'assemble_visibility' do
    let(:item) { double }
    let(:read_groups) { ['admin', 'archivist', 'fluffy'] }

     before do
       allow(item).to receive(:read_groups).and_return(read_groups)
     end

    it 'prints the visibility' do
      parsed = YAML::parse(visibility(item))
      expect(parsed.to_ruby["visibility"]).to eq ["fluffy"]
    end
  end
end
