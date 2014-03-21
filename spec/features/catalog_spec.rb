require 'spec_helper'

describe 'catalog' do
  describe 'search results' do
    context "when there is a collection" do
      before(:each) do
        FactoryGirl.create(:generic_collection)
      end
      it "should not show up in search results" do
        visit root_path(:search_field => "all_field")
        expect(page).not_to have_selector('.document')
      end
    end

    context "when there is an asset with a thumbnails" do
      let(:image) { FactoryGirl.create(:image, :with_tiff_datastream) }

      before(:each) do
        image
        image.create_derivatives
        visit root_path(:search_field => "all_field")
      end

      it "should show the thumbnail in search results" do
        expect(page).to have_selector(".document img")
        expect(page).to have_selector(".document img[src^='/thumbnails']")
      end
    end
  end
end
