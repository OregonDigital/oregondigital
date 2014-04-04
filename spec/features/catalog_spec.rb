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
      
      context "when the thumbnails are clicked" do
        it "should have clickable thumbnails", :js => true do
          expect(page).to have_selector(".document img[src^='/thumbnails']")
          find(".document img[src^='/thumbnails']").click
          expect(current_path).to eq catalog_path(:id => image.pid)
        end
      end
    end

    context "when an asset has CV fields" do
      let(:asset) do
        asset = FactoryGirl.build(:generic_asset, lcsubject: RDF::URI.new("http://id.loc.gov/authorities/subjects/sh85050282"))
        asset.descMetadata.lcsubject.first.set_value(RDF::SKOS.prefLabel, "Test Facet")
        asset.descMetadata.lcsubject.first.persist!
        asset.save
        asset
      end

      before(:each) do
        visit catalog_path(:id => asset.pid)
      end

      it "should show links to the CV facets" do
        expect(page).to have_link("Test Facet")
      end
    end
  end
end
