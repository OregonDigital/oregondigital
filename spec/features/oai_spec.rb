require 'spec_helper'

describe "OAI endpoint" do
  let(:asset_class) {GenericAsset}
  context "when there are assets" do
    let(:asset) {asset_class.new}
    before(:each) do
      asset.title = "Test Title"
      asset.review!
      visit oai_path(:verb => "ListRecords", :metadataPrefix => "oai_dc")
    end
    context "and they are generic assets" do
      it "should show them" do
        expect(page).to have_content("Test Title")
      end
    end
    context "and they are documents" do
      let(:asset_class) {Document}
      it "should show them" do
        expect(page).to have_content("Test Title")
      end
    end
    context "and they are not reviewed" do
      before do
        asset.reset_workflow!
        visit oai_path(:verb => "ListRecords", :metadataPrefix => "oai_dc")
      end
      it "should not show them" do
        expect(page).not_to have_content("Test Title")
      end
    end
  end
end
