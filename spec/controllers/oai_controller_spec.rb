require 'spec_helper'

describe OaiController, :resque => true do
  describe '#index' do
    context "when given a request" do
      let(:format) {RDF::URI.new("http://purl.org/NET/mediatypes/image/tiff")}
      let(:lcsubject) {RDF::URI.new("http://id.loc.gov/authorities/subjects/sh85050282")}
      let(:lcname) {RDF::URI.new("http://id.loc.gov/authorities/names/nr93013379")}
      let(:lcname2) {RDF::URI.new("http://id.loc.gov/authorities/names/no00013511")}
      let(:type) {RDF::URI.new("http://purl.org/dc/dcmitype/Image")}
      let(:rights){RDF::URI.new("http://creativecommons.org/licenses/by-nc-nd/4.0/")}
      let(:generic_asset_1) do
        f = FactoryGirl.build(:generic_asset)
        f.title = "gen asset 1"
        f.descMetadata.format = format
        f.descMetadata.lcsubject = lcsubject
        f.descMetadata.creator = [lcname,lcname2]
        f.descMetadata.rights = rights
        f.descMetadata.type = type
        f.descMetadata.date = "2012-12-12"
        f.descMetadata.description = "This thing is a thing."
        f.descMetadata.identifier = "blahblah123"
        f.descMetadata.earliestDate = "1983"
        f.descMetadata.latestDate = "1984"
        f.save
        f
      end

      let(:generic_asset_2) do
        f = FactoryGirl.build(:generic_asset)
        f.descMetadata.format = format
        f.title = "gen asset 2"
        f.save
        f
      end
      let(:generic_asset_3) do
        f = FactoryGirl.create(:generic_asset)
        f.descMetadata.format = format
        f.title = "gen asset 3"
        f.save
        f
      end
      before (:each) do
        generic_asset_1.reload
        generic_asset_2
        generic_asset_3
      end
      context "and request is list" do
        before do
          get :index, :verb => "ListRecords", :metadataPrefix => "oai_dc"
        end
        it "should work" do
          expect(response).to be_success
        end
      end
      context 'and request is get' do
        before do
          get :index, :verb => "GetRecord", :metadataPrefix => "oai_dc", :identifier=>"#{generic_asset_1.id}"
        end
        it "should work" do
          expect(response).to be_success
        end
      end
      context "and request is identifiers" do
        before do
          get :index, :verb => "ListIdentifiers", :metadataPrefix => "oai_dc"
        end
        it "should work" do
          expect(response).to be_success
        end
      end
      context "and request is for metadata formats" do
        before do
          get :index, :verb => "ListMetadataFormats"
        end
        it "should work" do
          expect(response).to be_success
        end
      end
      context "and request is for identity" do
        before do
          get :index, :verb => "Identify"
        end
        it "should work" do
          expect(response).to be_success
        end
      end
    end
    context "when asked for sets" do
      let(:generic_coll_1) do
        g = FactoryGirl.build(:generic_collection)
        g.title = "Collection_1"
        g.description = "The first collection"
        g.save
        g
      end
      let(:institution){RDF::URI.new("http://dbpedia.org/resource/University_of_Oregon")}
      let(:generic_coll_2) do
        g = FactoryGirl.build(:generic_collection)
        g.title = "Collection_2"
        g.institution = institution
        g.save
        g
      end
      before do
        generic_coll_1
        generic_coll_2
        get :index, :verb => "ListSets"
      end
      it "should work" do
        expect(response).to be_success
      end
    end

  end
end
