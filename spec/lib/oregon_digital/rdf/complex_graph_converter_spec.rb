require 'spec_helper'

RSpec.describe OregonDigital::RDF::ComplexGraphConverter do
  context "when given a complex item graph" do
    subject { OregonDigital::RDF::ComplexGraphConverter.new(graph_resource).run }
    let(:resource) { FactoryGirl.create(:generic_asset) }
    let(:graph_resource) { resource.resource }
    let(:resource_2) { FactoryGirl.create(:generic_asset) }
    let(:resource_3) { FactoryGirl.create(:generic_asset) }
    let(:statements) { subject.statements }
    before do
      list = OregonDigital::RDF::List.from_uri(RDF::Node.new,graph_resource)
      list << resource_2
      list << resource_3
      list[0].title = "Test"
      graph_resource << list[0]
      graph_resource << [graph_resource.rdf_subject, OregonDigital::Vocabularies::OREGONDIGITAL.contents, list.rdf_subject]
      resource.descMetadata.od_content = list
      resource.save
    end
    describe "#run" do
      it "should return a graph without lists" do
        expect(subject).to be_kind_of RDF::Graph
        expect(statements).not_to have_object RDF.List
        expect(statements).not_to have_object RDF.nil
        expect(statements).not_to have_predicate RDF.first
        expect(statements).not_to have_predicate RDF.rest
        expect(statements.query([graph_resource.rdf_subject, OregonDigital::Vocabularies::OREGONDIGITAL.contents, nil]).to_a.find{|x| x.object.node?}).to be_nil
      end
      it "should have contents statements" do
        expect(subject).to have_statement RDF::Statement.from([graph_resource.rdf_subject, OregonDigital::Vocabularies::OREGONDIGITAL.contents, resource_2.resource.rdf_subject])
        expect(subject).to have_statement RDF::Statement.from([graph_resource.rdf_subject, OregonDigital::Vocabularies::OREGONDIGITAL.contents, resource_3.resource.rdf_subject])
      end
      it "should create a hydra::works connection" do
        expect(subject.query([graph_resource.rdf_subject, OregonDigital::Vocabularies::IANA["first"], nil]).to_a.length).to eq 1
        expect(subject.query([nil, OregonDigital::Vocabularies::ORE.proxyFor, resource_2.resource.rdf_subject]).to_a.length).to eq 1
        expect(subject.query([nil, OregonDigital::Vocabularies::IANA["next"], nil]).to_a.length).to eq 1
        expect(subject.query([nil, OregonDigital::Vocabularies::IANA["previous"], nil]).to_a.length).to eq 1
        expect(subject.query([graph_resource.rdf_subject, OregonDigital::Vocabularies::IANA["last"], nil]).to_a.length).to eq 1
        expect(subject.query([nil, RDF::DC.title, "Test"]).to_a.length).to eq 1
      end
      it "should return a graph with the basic properties" do
        expect(subject).to have_statement RDF::Statement.from([graph_resource.rdf_subject, RDF::DC.title, resource.title])
      end
    end
  end
end
