require 'spec_helper'

describe SetsController do
  describe "#index" do
    context "when there are unreviewed collections" do
      let(:collection_1) { FactoryGirl.create(:generic_collection) }
      let(:collection_2) { FactoryGirl.create(:generic_collection, :pending_review) }
      before do
        collection_1
        collection_2
        get :index
      end
      it "should only display the reviewed ones" do
        expect(assigns(:collections).length).to eq 1
      end
    end
  end
end
