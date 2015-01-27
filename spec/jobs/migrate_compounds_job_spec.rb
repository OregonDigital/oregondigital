require 'spec_helper'

RSpec.describe MigrateCompoundsJob do
  describe ".perform" do
    context "with a persisted RDF List compound object" do
      subject { MigrateCompoundsJob.perform }
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
        resource.save
        Blacklight.solr.add resource.to_solr.merge(:desc_metadata__od_content_references_ssim => [resource_2.resource.rdf_subject.to_s, resource_3.resource.rdf_subject.to_s])
        Blacklight.solr.commit
        subject
      end
      it "should change things to new setup" do
        g = GenericAsset.find(resource.pid)
        expect(g.od_content.first).to eq resource_2
      end
    end
  end
end
