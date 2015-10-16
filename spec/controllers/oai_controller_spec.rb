require 'spec_helper'

describe OaiController do
  describe '#index' do
    context "when asked for records" do
      let(:format) {RDF::URI.new("http://purl.org/NET/mediatypes/image/tiff")}
    
      let(:generic_asset_1) do
        f = FactoryGirl.build(:generic_asset)
        f.descMetadata.format = format
        f.save
        f
      end
    
      let(:generic_asset_2) do
        f = FactoryGirl.build(:generic_asset)
        f.descMetadata.format = format
        f.save
        f
      end
      let(:generic_asset_3) do
        f = FactoryGirl.create(:generic_asset)
        f.descMetadata.format = format
        f.save
        f
      end
      before(:each) do
        generic_asset_1
        sleep(1)
        generic_asset_2
        generic_asset_1.reload
        generic_asset_2.reload
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
        g.save
        g
      end
      let(:generic_coll_2) do
        g = FactoryGirl.build(:generic_collection)
        g.save
        g
      end
      before(:each) do
        generic_coll_1
        generic_coll_2
        get :index, :verb => "ListSets", :metadataPrefix => "oai_dc"
      end
      it "should work" do
        expect(response).to be_success
      end
    end
  end
end
