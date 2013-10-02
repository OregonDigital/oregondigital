require 'spec_helper'

describe "item review behavior" do
  let (:item) {GenericAsset.new}
  context "with an unreviewed item" do
    before(:each) do
      item.read_groups = ["public"]
      item.save
    end
    context "on the catalog page" do
      before(:each) do
        visit catalog_index_path(:search_field => 'all_fields')
      end
      it "should not show the item" do
        expect(page).not_to have_selector('.document')
      end
    end
  end
  context "with a reviewed item" do
    before(:each) do
      item.read_groups = ["public"]
      item.review!
      expect(item).to be_persisted
    end
    context "on the catalog page" do
      before(:each) do
        visit catalog_index_path(:search_field => 'all_fields')
      end
      it "should show the item" do
        expect(page).to have_selector('.document', :count => 1)
      end
    end
  end
end
