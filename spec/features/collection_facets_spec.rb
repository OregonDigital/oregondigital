require 'spec_helper'

describe 'collection facets' do
  context "when there is an item in a collection" do
    let(:item) do
      i = GenericAsset.new
      i.collections << collection
      i.review
      i.read_groups = ["public"]
      i.save
      i.reload
    end
    let(:collection) do
      i = GenericCollection.new
      i.title = "Test Collection"
      i.save
      i
    end
    context "and it has a title" do
      before(:each) do
        item
        visit root_path
      end
      it "should display the collection title as a facet" do
        expect(page).to have_content("Test Collection")
      end
    end
    context "and it does not have a title" do
      before(:each) do
        item
        collection.title = ""
        collection.save
        visit root_path
      end
      it "should display the collection pid as a facet" do
        expect(page).to have_content(collection.pid)
      end
    end
  end
end
