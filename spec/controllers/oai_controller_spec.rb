require 'spec_helper'

describe OaiController do
  describe '#index' do
    let(:collection_1) do
      f = FactoryGirl.build(:generic_collection)
      f.save
      f
    end
    let(:generic_asset_1) do
      f = FactoryGirl.build(:generic_asset)
      f.save
      f
    end
    let(:generic_asset_2) do
      f = FactoryGirl.build(:generic_asset)
      f.save
      f
    end
    let(:generic_asset_3) {FactoryGirl.create(:generic_asset)}
    before(:each) do
      generic_asset_1
      sleep(1)
      generic_asset_2
      generic_asset_1.reload
      generic_asset_2.reload
      #expect(generic_asset_1.modified_date).not_to eq generic_asset_2.modified_date
      get :index, :verb => "ListRecords", :metadataPrefix => "oai_dc"
    end


    it "should work" do
      expect(response).to be_success
    end
  end
end
