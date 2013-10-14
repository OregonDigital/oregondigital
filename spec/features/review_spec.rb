require 'spec_helper'

describe "item review behavior" do
  context "with an unreviewed item" do
    context "on the catalog page" do
      before(:each) do
        FactoryGirl.create(:generic_asset, :pending_review)
        visit catalog_index_path(:search_field => 'all_fields')
      end
      it "should not show the item" do
        expect(page).not_to have_selector('.document')
      end
    end
  end
  context "with a reviewed item" do
    context "on the catalog page" do
      before(:each) do
        FactoryGirl.create(:generic_asset)
        visit catalog_index_path(:search_field => 'all_fields')
      end
      it "should show the item" do
        expect(page).to have_selector('.document', :count => 1)
      end
    end
  end
end
