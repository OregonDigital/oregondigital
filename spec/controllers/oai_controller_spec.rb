require 'spec_helper'

describe OaiController do
  describe '#index' do
    context "when asked for records" do
      let(:format) {RDF::URI.new("http://purl.org/NET/mediatypes/image/tiff")}
      #let(:formaturi) {"http://purl.org/NET/mediatypes/image/tiff"}
      #let(:label) {"image/tiff"}
      #let(:format) do
        #frm = OregonDigital::ControlledVocabularies::Format.new(formaturi)
        #frm.set_value(RDF::SKOS.prefLabel, label)
        #frm.persist!
      #end
      let(:generic_asset_1) do
        #GenericAsset.any_instance.stub(:queue_fetch).and_return(true)
        f = FactoryGirl.build(:generic_asset)
        f.descMetadata.format = format
        f.title = "gen asset 1"
        f.save
        f
      end

      let(:generic_asset_2) do
        f = FactoryGirl.build(:generic_asset)
        f.descMetadata.format = format
        f.title = "gen asset 2"
        f.save
        f
      end
      let(:generic_asset_3) do
        f = FactoryGirl.create(:generic_asset)
        f.descMetadata.format = format
        f.title = "gen asset 3"
        f.save
        f
      end
      before do
        generic_asset_1
        generic_asset_2
        generic_asset_3

        get :index, :verb => "ListRecords", :metadataPrefix => "oai_dc"
      end
      it "should work" do
        expect(response).to be_success
      end
    end
    context "when asked for sets" do
      let(:generic_coll_1) do
        g = FactoryGirl.build(:generic_collection)
        g.title = "Collection_1"
        g.description = "The first collection"
        g.save
        g
      end
      let(:generic_coll_2) do
        g = FactoryGirl.build(:generic_collection)
        g.title = "Collection_2"
        g.description = "The second collection"
        g.save
        g
      end
      before do
        generic_coll_1
        generic_coll_2
        get :index, :verb => "ListSets"
      end
      it "should work" do
        expect(response).to be_success

      end
    end
  end
end
