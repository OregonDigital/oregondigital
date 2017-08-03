require 'spec_helper'

describe 'Advanced Search' do
  let(:item) do
    i = FactoryGirl.build(:generic_asset)
    i.title = "Test Title"
    i.description = "Test Description"
    i.lcsubject = RDF::URI('http://id.loc.gov/authorities/subjects/sh85048622')
    i.lcsubject.first << [i.lcsubject.first.rdf_subject, RDF::SKOS.prefLabel, "Test Facet"]
    i.lcsubject.first.persist!
    i.review!
    i
  end
  before do
    item
  end
  context "when you go into advanced search" do
    before do
      visit advanced_search_path
    end
    it "should show all available facets" do
      expect(page).to have_content("Test Facet")
    end
    it "should not show facet URIs" do
      expect(page).not_to have_content(item.lcsubject.first.rdf_subject.to_s)
    end
    context "and you search for a title" do
      let(:search_title) {"Title"}
      before do
        fill_in "Title:", :with => search_title
        within("form.advanced") do
          click_button "Search"
        end
        expect(page).to have_content("You searched for")
      end
      context "and the document matches" do
        it "should show" do
          expect(page).to have_selector(".document", :count => 1)
        end
      end
      context "and the document doesn't match at all" do
        let(:search_title) {"Blabla"}
        it "should not show" do
          expect(page).not_to have_selector(".document")
        end
      end
      context "and a different field matches for the document" do
        let(:search_title) {"Description"}
        it "should not show" do
          expect(page).not_to have_selector(".document")
        end
      end
    end
    context "and you choose a facet", :js => true do
      before do
        find(".blacklight-desc_metadata__lcsubject_label_sim").click
        expect(page).to have_content("Test Facet")
        find("label.checkbox").click
        within("form.advanced") do
          click_button "Search"
        end
      end
      it "should show that facet on the left" do
        expect(page).to have_content("Any of:")
        expect(find("span.selected")).to have_content("Test Facet")
      end
      it "should show it as an above facet" do
        expect(page).to have_content("You searched for")
        within(".results") do
          expect(page).to have_content("Test Facet")
        end
      end
      it "should not show the facet URI" do
        expect(page).to have_content("You searched for")
        expect(page).not_to have_content(item.lcsubject.first.rdf_subject.to_s)
      end
    end
  end
end
