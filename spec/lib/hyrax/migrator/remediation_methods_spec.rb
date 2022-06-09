require 'spec_helper'
describe Hyrax::Migrator::RemediationMethods do
  include Hyrax::Migrator::RemediationMethods
  describe 'remediate' do
    let(:graph) do
      g = RDF::Graph.new
      subj = RDF::URI('http://oregondigital.org/resource/oregondigital:abcde1234')
      pred = RDF::URI('http://purl.org/dc/terms/spatial')
      obj = RDF::URI('http://sws.geonames.org/123456/')
      g << RDF::Statement(subj, pred, obj)
      g
    end
    let(:remediation) { ['fix_geonames'] }

    it 'remediates the graph' do
      new_graph = remediate(remediation, graph)
      expect(new_graph.statements.first.object.to_s).to eq 'https://sws.geonames.org/123456/'
    end

    it 'uses a copy of the graph' do
      expect(remediate(remediation, graph)).not_to equal graph
    end
  end
end
