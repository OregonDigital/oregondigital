require 'spec_helper'

describe "SetsController /index" do
  let(:collection_pid) {'oregondigital:monkeys'}
  let(:collection) { FactoryGirl.create(:generic_collection, :has_pid, pid: collection_pid) }
  let(:subject_1) {RDF::URI.new("http://id.loc.gov/authorities/subjects/sh85050282")}
  let(:subject_2) {RDF::URI.new("http://id.loc.gov/authorities/subjects/sh85123395")}
  let(:item) do
    g = FactoryGirl.build(:generic_asset, lcsubject: subject_1)
    g.descMetadata.lcsubject.first.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("Test Facet", :language => :en))
    g.descMetadata.lcsubject.first.persist!
    g.save
    g
  end
  let(:item2) do
    g = FactoryGirl.build(:generic_asset, lcsubject: subject_2)
    g.descMetadata.lcsubject.first.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("Other Facet", :language => :en))
    g.descMetadata.lcsubject.first.persist!
    g.save
    g
  end

  before(:each) do
    collection
  end
  context "when there are sets" do
    let(:collection2_pid) {'oregondigital:photos'}                                                                           
    let(:collection2) do                                                                                                       
      g = FactoryGirl.create(:generic_collection, :has_pid, pid: collection2_pid)                                              
      g.title = "A Photo Collection"
      g.save                                                                                                                  
      g 
    end
    before(:each) do
      collection2
      visit sets_path
    end
    it "should show a list of all the collections" do
      expect(page).to have_content(collection.title)
    end
    it "should sort the list of collections A-Z (ignoring 'A', 'An, and 'The')" do
      expect(page.body.index(collection.title)).to be < page.body.index(collection2.title)
    end
  end
  context "when there are facetable items" do
    before(:each) do
      item
      item2
      visit sets_path
    end
    it "should show the facets" do
      expect(page).to have_content(item.lcsubject.map(&:rdf_label).join)
      expect(page).to have_content(item2.lcsubject.map(&:rdf_label).join)
    end
    context "and the facets are clicked" do
      before(:each) do
        click_link "Test Facet"
      end
      it "should show one result" do
        expect(page).to have_selector('.document', :count => 1)
        expect(page).to have_content(item.lcsubject.map(&:rdf_label).join)
      end
    end
  end
  context "when requesting a collection sub-page" do
    before(:each) do
      item.set << collection
      item.save
      item2
      visit sets_path(:set => collection, :page => "related")
    end
    context "when it exists" do
      let(:collection_pid) {'oregondigital:braceros'}
      it "should show that set page" do
        expect(page).to have_content("Additional Braceros Resources")
      end
      it "should have a readable path" do
        expect(current_path).to eq "/sets/braceros/page/related"
      end
    end
    context "when it does not exist" do
      it "should show the generic collection landing page" do
        within("#main-container h2") do
          expect(page).to have_content(collection.title)
        end
      end
    end
  end
  context "when requesting a specific collection" do
    before(:each) do
      item.set << collection
      item.save
      item2
      visit sets_path(:set => collection)
    end
    context "that does have a set page" do
      let(:collection_pid) {'oregondigital:braceros'}
      let(:collection) do
        g = FactoryGirl.create(:generic_collection, :has_pid, pid: collection_pid)
        g.institution = OregonDigital::ControlledVocabularies::Organization.new('http://dbpedia.org/resource/Oregon_State_University')
        g.institution.first.set_value(RDF::SKOS.prefLabel, "Oregon State University")
        g.institution.first.persist!
        g.save
        g
      end
      it "should show the facets" do
        expect(page).to have_content("Test Facet")
      end
      it "should show the appropriate institution layout" do
        expect(collection.resource.institution.first.rdf_label.first).to eq "Oregon State University"
        within("#footer .contact") do
          expect(page).to have_content("Oregon State University")
        end
      end
      context "and then an item is clicked" do
        let(:collection) do
          g = FactoryGirl.create(:generic_collection, :has_pid, pid: collection_pid)
          g.institution = OregonDigital::ControlledVocabularies::Organization.new('http://dbpedia.org/resource/Oregon_State_University')
          g.institution.first.set_value(RDF::SKOS.prefLabel, "Oregon State University")
          g.institution.first.persist!
          g.save
          item2.set = g
          item2.save
          g
        end
        before do
          click_button "search"
          expect(page).to have_selector('.document', :count => 2)
          click_link item.title
        end
        it "should maintain context" do
          within("#footer .contact") do
            expect(page).to have_content("Oregon State University")
          end
        end
        it "should have a link to the collection" do
          expect(page).to have_link collection.title
        end
        # Pending until we can patch ActiveFedora to accept an argument for
        # using load_instance_from_solr
        xit "should not ask Fedora" do
          expect(ActiveFedora::DigitalObject).not_to receive(:find)
          visit current_path
          expect(page).to have_link collection.title
        end
        context "and a facet is clicked" do
          before do
            click_link "Test Facet"
          end
          it "should stay in set context" do
            within("#footer .contact") do
              expect(page).to have_content("Oregon State University")
            end
          end
        end
        context "and start over is clicked", :js => true do
          before do
            find("#startOverLink").click
          end
          it "should go to the root of the set page" do
            expect(current_path).to eq sets_path(:set => collection.to_param)
          end
        end
        it "should show the previous document link", :js => true do
          expect(page).to have_selector("a.previous")
        end
        context "then previous link is clicked", :js => true do
          before do
            find("a.previous").click
          end
          it "should maintain context" do
            expect(page).to have_content(item2.title)
            within("#footer .contact") do
              expect(page).to have_content("Oregon State University")
            end
          end

        end
      end
      it "should not show the collection facets" do
        within("#facets") do
          expect(page).not_to have_content("Test Collection")
        end
      end
      it "should include the second half of the collection pid in the path" do
        expect(current_path).to eq "/sets/#{collection.pid.split(':').last}"
      end
      it "should show the collection landing page" do
        expect(page).to have_content("The Braceros Program")
      end
      it "should not show facets for items not in the collection" do
        expect(page).not_to have_content("Other Facet")
      end
      it "should have a working browse items button" do
        click_link "Browse Items"
        expect(page).to have_selector('.document', :count => 1)
      end
      context "when you search for a string" do
        before do
          fill_in "Search...", :with => "Blablabla"
          click_button "search"
          expect(page).not_to have_selector(".document")
        end
        context "and then you click browse items" do
          before do
            click_link "Browse Items"
          end
          it "should show all the items" do
            expect(page).to have_selector(".document", :count => 1)
          end
        end
      end
      context "when you search" do
        before(:each) do
          click_button "search"
        end
        it "should keep in the sets controller" do
          expect(current_path).to include collection.pid.split(':').last
        end
        it "should not return items from other collections" do
          expect(page).to have_selector('.document', :count => 1)
        end
      end
    end
    context "that does not have a set page" do
      it "should show the generic collection landing page" do
        within("#main-container h2") do
          expect(page).to have_content(collection.title)
        end
      end
    end
  end
end
