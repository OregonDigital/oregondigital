require 'spec_helper'

describe 'collection facets' do
  context "when there is an item in a collection", :resque => true do
    let(:item) do
      g = FactoryGirl.build(:generic_asset, :in_collection!, lcsubject: RDF::URI.new("http://id.loc.gov/authorities/subjects/sh85050282"))
      g.descMetadata.lcsubject.first.set_value(RDF::SKOS.prefLabel, "Test Facet")
      g.descMetadata.lcsubject.first.persist!
      g.descMetadata.set << new_collection
      g.save
      g
    end
    let(:new_collection) {FactoryGirl.create(:generic_collection)}
    let(:collection) { item.set.first }

    before(:each) do
      item
    end

    context "and it has a title" do
      before(:each) do
        visit root_path
      end
      it "should display the collection title as a facet" do
        within '#facets' do
          expect(page).to have_content(new_collection.title)
          expect(page).to have_content(collection.title)
        end
      end
      context "and the facet is clicked" do
        before do
          click_link collection.title
          expect(current_path).to eq "/sets/#{collection.pid.split(':').last}"
        end
        it "should redirect to the collection landing page" do
          expect(current_path).to eq "/sets/#{collection.pid.split(':').last}"
        end
        it "should have an appropriate title" do
          expect(page.title.strip).to eq "#{collection.title} | Oregon Digital"
        end
        context "and then a search is done" do
          before do
            fill_in "Search...", :with => "Can't Find Me"
            click_button "search"
            expect(page).to have_content("No entries found")
          end
          it "should have an appropriate title" do
            expect(page.title.strip).to eq "Search Results | #{collection.title} | Oregon Digital"
          end
        end
      end
    end
    context "and search results are being displayed" do
      context "when the facet is clicked" do
        it "should not go to the collection landing page" do
          visit root_path(:search_field => "all_fields")
          click_link collection.title
          expect(current_path).not_to eq "/sets/#{collection.pid.split(':').last}"
        end
        context "and then a more precise search is done" do
          it "should still show the facet" do
            visit root_path(:search_field => "all_fields")
            click_link collection.title
            fill_in "Search...", :with => "Return Nothing"
            click_button "search"
            within("#appliedParams") do
              expect(page).to have_content(collection.title)
            end
          end
        end
      end
    end
    context "when the subject is clicked" do
      before(:each) do
        visit root_path
        click_link item.lcsubject.first.rdf_label.first
      end
      it "should go to /catalog" do
        expect(current_path).to include "catalog"
      end
      context "and then the collection facet is clicked" do
        before(:each) do
          click_link collection.title
        end
        it "should not go to the collection landing page" do
          expect(page).to have_selector(".filter-desc_metadata__set_label_sim")
          expect(current_path).not_to eq "/sets/#{collection.pid.split(':').last}"
        end
      end
    end
    context "and the collection object doesn't exist" do
      before(:each) do
        collection.destroy
        new_collection.destroy
        visit root_path
      end
      it "should display nothing" do
        within '#facets' do
          expect(page).not_to have_content("Collection")
        end
      end
    end
    context "and it does not have a title" do
      before(:each) do
        collection.title = ""
        new_collection.title = ""
        collection.save
        new_collection.save
        visit root_path
      end
      it "should not display anything" do
        within '#facets' do
          expect(page).not_to have_content("Collection")
        end
      end
    end
  end
end
