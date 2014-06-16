require 'spec_helper'

describe ResourceController do
  describe '#show' do
    let(:asset) {}
    let(:pid) {"oregondigital:1"}
    before do
      asset
    end
    context "when there is an asset" do
      let(:asset) {GenericAsset.create(:pid => pid)}
      before do
        get :show, :id => pid
      end
      it "should redirect to the catalog" do
        expect(response).to redirect_to catalog_path(pid)
      end
      it "should be a 303 redirect" do
        expect(response.status).to eq 303
      end
    end
    context "when there is not an asset" do
      it "should return a 404" do
        expect{get :show, :id => pid}.to raise_error ActionController::RoutingError
      end
    end
  end
end
