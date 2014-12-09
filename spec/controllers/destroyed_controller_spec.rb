require 'spec_helper'

describe DestroyedController do
  let(:user) {}
  let(:core_asset) { instance_double("GenericAsset") }
  # I do this a lot. Can there be a "stubbed factory" or something?
  let(:asset) do
    core_asset.stub(:pid).and_return("oregondigital:bla")
    core_asset.stub(:undelete!)
    core_asset
  end
  before do
    controller.stub(:asset).and_return(asset)
    sign_in user if user
  end

  describe "GET undelete" do
    def undelete_asset
      get :undelete, :id => asset.pid
    end
    context "when logged in as a user" do
      it "should be unauthorized" do
        undelete_asset
        expect(flash[:alert]).to eq I18n.t('oregondigital.destroyed.unauthorized') 
        expect(response).to redirect_to new_user_session_path
      end
    end
    context "when logged in as an admin" do
      let(:user) { FactoryGirl.create(:admin) }
      it "should call undelete! on asset" do
        expect(asset).to receive(:undelete!)
        undelete_asset
      end
      it "should set flash message" do
        undelete_asset
        expect(flash[:notice]).to eq I18n.t('oregondigital.destroyed.undelete.success')
      end
    end
  end
end
