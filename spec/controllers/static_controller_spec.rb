require 'spec_helper'

describe StaticController do
  describe "#controlled_vocabularies" do
    context "When a user visits the page" do
      before do
        get :controlled_vocabularies
      end
      it "should work" do
        expect(response).to be_success
      end
    end
  end
end
