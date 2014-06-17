require 'spec_helper'

describe "Resource URIs" do
  context "when there is an asset" do
    let(:asset) {FactoryGirl.create(:generic_asset)}
    before do
      asset
    end
    context "and its resource URI is navigated to" do
      before do
        visit asset.resource.rdf_subject.path
      end
      it "should redirect to catalog" do
        expect(current_path).to eq catalog_path(:id => asset.pid)
      end
    end
  end
end
