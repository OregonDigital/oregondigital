require 'spec_helper'

describe 'collection facets' do
  context "when there is an item in a collection" do
    let(:item) { FactoryGirl.create(:generic_asset, :in_collection!, subject: "http://id.loc.gov/authorities/subjects/sh96005121") }
    let(:collection) { item.collections.first }

    before(:each) do
      item
    end

    context "and it has a title" do
      before(:each) do
        visit root_path
      end
      it "should display the collection title as a facet" do
        expect(page).to have_content(collection.title)
      end
      it "should go to the landing page when clicked" do
        click_link collection.title
        expect(current_path).to eq "/sets/#{collection.pid.split(':').last}"
      end
    end
    context "and search results are being displayed" do
      before(:each) do
        visit root_path(:search_field => "all_fields")
      end
      context "when the facet is clicked" do
        before(:each) do
          click_link collection.title
        end
        it "should not go to the collection landing page" do
          expect(current_path).not_to eq "/sets/#{collection.pid.split(':').last}"
        end
      end
    end
    context "when the subject is clicked" do
      before(:each) do
        visit root_path
        click_link item.subject.first
      end
      context "and then the collection facet is clicked" do
        before(:each) do
          click_link collection.title
        end
        it "should not go to the collection landing page" do
          expect(page).to have_selector(".filter-desc_metadata__set_sim")
          expect(current_path).not_to eq "/sets/#{collection.pid.split(':').last}"
        end
      end
    end
    context "and the collection object doesn't exist" do
      before(:each) do
        collection.destroy
        visit root_path
      end
      it "should display the collection pid as a facet" do
        expect(page).to have_content(collection.pid)
      end
    end
    context "and it does not have a title" do
      before(:each) do
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
