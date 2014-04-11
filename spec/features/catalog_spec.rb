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
      context "when the asset is an image" do
        it_should_behave_like "a thumbnail asset" do
          let(:asset) {FactoryGirl.create(:image, :with_tiff_datastream)}
        end
      end
      context "when the asset is a document" do
        it_should_behave_like "a thumbnail asset" do
          let(:asset) do
            document = Document.new
            file = File.open(File.join(fixture_path, 'fixture_pdf.pdf'), 'rb')
            document.add_file_datastream(file, :dsid => 'content')
            OregonDigital::FileDistributor.any_instance.stub(:base_path).and_return(Rails.root.join("media","test"))
            document.title = "Filler Title"
            document.review!
            document
          end 
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
