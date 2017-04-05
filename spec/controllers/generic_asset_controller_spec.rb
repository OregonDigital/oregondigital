require 'spec_helper'

describe GenericAssetController do
  let(:core_asset) { FactoryGirl.create(:generic_asset) }
  let(:asset) do
    core_asset.stub(:pid).and_return("oregondigital:bla")
    core_asset
  end
  describe 'DELETE destroy' do
    before do
      sign_in user if user
      controller.instance_variable_set(:@generic_asset, asset)
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
        let(:user) { FactoryGirl.create(:admin) }
        it "should be authorized" do
          expect{delete_asset}.not_to raise_error
        end
        it "should call soft_destroy" do
          expect(asset).to receive(:soft_destroy)
          delete_asset
          expect(flash[:notice]).to eq I18n.t("oregondigital.generic_asset.destroy")
        end
      end
    end
  end
end
