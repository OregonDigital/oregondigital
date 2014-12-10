require 'spec_helper'

describe GenericAssetController do
  let(:core_asset) { instance_double("GenericAsset") }
  let(:asset) do
    core_asset.stub(:pid).and_return("oregondigital:bla")
    core_asset.stub(:soft_destroy)
    core_asset
  end
  describe 'DELETE destroy' do
    before do
      sign_in user if user
      controller.instance_variable_set(:@generic_asset, asset)
      controller.stub(:asset).and_return(asset)
    end
    def delete_asset
      delete :destroy, :id => asset.pid
    end
    context "when given a generic asset" do
      let(:user) {}
      context "when logged in as a user" do
        it "should be unauthorized" do
          expect{delete_asset}.to raise_error(CanCan::AccessDenied)
        end
      end
      context "when logged in as an admin" do
        before do
          controller.stub(:authorize!)
        end
        it "should be authorized" do
          expect{delete_asset}.not_to raise_error
        end
        it "should call soft_destroy" do
          expect(asset).to receive(:soft_destroy)
          delete_asset
          expect(flash[:notice]).to eq I18n.t("oregondigital.generic_asset.destroy")
        end
        it "should discover the appropriate asset" do
          controller.instance_variable_set(:@generic_asset, nil)
          binding.pry
          expect(GenericAsset).to receive(:find).with(asset.pid).and_return(asset)
          delete_asset
          expect(assigns(:generic_asset)).to eq asset
        end
      end
    end
  end
  describe "GenericAssetController::AssetAdapter" do
    describe ".call" do
      let(:asset) { instance_double("GenericAsset") }
      let(:result) { GenericAssetController::AssetAdapter.call(asset) }
      context "when given an object that can be adapted" do
        let(:new_asset) { instance_double("GenericAsset") }
        before do
          asset.stub(:adapt_to_cmodel).and_return(new_asset)
        end
        it "should call it" do
          expect(result).to eq new_asset
        end
      end
      context "when given an object that can't be adapted" do
        it "should give it back" do
          expect(result).to eq asset
        end
      end
      context "when given a nil value" do
        let(:result) {GenericAssetController::AssetAdapter.call(nil)}
        it "should give it back" do
          expect(result).to eq nil
        end
      end
    end
  end
end
