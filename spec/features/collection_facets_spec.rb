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
      it "should go to the landing page when clicked" do
        click_link "Test Collection"
        expect(current_path).to eq "/sets/#{collection.pid.split(':').last}"
      end
    end
    context "and search results are being displayed" do
      before(:each) do
        item.subject = "Test Subject"
        item.save
        collection.title = "Test Collection"
        collection.save
        visit root_path(:search_field => "all_fields")
      end
      context "when the facet is clicked" do
        before(:each) do
          click_link "Test Collection"
        end
        it "should not go to the collection landing page" do
          expect(current_path).not_to eq "/sets/#{collection.pid.split(':').last}"
        end
      end
    end
    context "when the subject is clicked" do
      before(:each) do
        item.subject = "Test Subject"
        item.save
        collection.title = "Test Collection"
        collection.save
        visit root_path
        click_link "Test Subject"
      end
      context "and then the collection facet is clicked" do
        before(:each) do
          click_link "Test Collection"
        end
        it "should not go to the collection landing page" do
          expect(page).to have_selector(".filter-desc_metadata__set_sim")
          expect(current_path).not_to eq "/sets/#{collection.pid.split(':').last}"
        end
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
