require 'spec_helper'

describe CatalogController do
  describe 'GET show' do
    let(:core_asset) { FactoryGirl.build(:generic_asset) }
    let(:asset) { core_asset }
    let(:document) { asset.to_solr }
    let(:user) { FactoryGirl.build(:user) }
    let(:soft_destroyed) do
      core_asset.soft_destroy
      core_asset
    end
    before do
      sign_in user
      asset.save
      get :show, :id => asset.pid
    end
    context "when an admin" do
      let(:user) { FactoryGirl.create(:admin) }
      context "when the asset is soft destroyed" do
        let(:asset) { soft_destroyed }
        it "should be found" do
          expect(response).to be_success
        end
      end
    end
    context "when a user" do
      context "when the asset is built" do
        it "should be a success" do
          expect(response).to be_success
        end
      end
      context "when the asset is soft destroyed" do
        let(:asset) { soft_destroyed }
        it "should be not found" do
          expect(response.code).to eq "302"
          expect(flash[:alert]).to include "do not have sufficient"
        end
      end
    end
  end
end
