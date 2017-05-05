require 'spec_helper'

shared_examples "OAI endpoint" do |parameter|
  let(:asset_class) {GenericAsset}

  context "when there are assets" do
    let(:lcname) {RDF::URI.new("http://id.loc.gov/authorities/names/nr93013379")}
    let(:lcname2) {RDF::URI.new("http://id.loc.gov/authorities/names/no00013511")}
    let(:lcsubj) {RDF::URI.new("http://id.loc.gov/authorities/subjects/sh2003003075")}
    let(:rights) {RDF::URI.new("http://creativecommons.org/licenses/by-nc-nd/4.0/")}
    let(:opns) {RDF::URI.new("http://opaquenamespace.org/ns/creator/mylittlecreator")}
    let(:mtype) {RDF::URI.new("https://w3id.org/spar/mediatype/image/tiff")}
    let(:geo) {RDF::URI.new("http://sws.geonames.org/5129691")}
    let(:pset) {GenericCollection.new(pid:"oregondigital:myset")}
    let(:find) {RDF::Literal.new("http://blahblah.org")}
    let(:asset) {asset_class.new}

    before(:each) do
      asset.title = "Test Title"
      asset.descMetadata.creator = [lcname,lcname2]
      asset.descMetadata.creator.first.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("Miyazaki, Hayao, 1942-", :language => :en))
      asset.descMetadata.creator.first.persist!
      asset.descMetadata.creator.second.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("Hisaishi, Joe", :language => :en))
      asset.descMetadata.creator.second.persist!
      asset.descMetadata.contributor =[opns]
      asset.descMetadata.contributor.first.persist!
      asset.descMetadata.identifier = "blahblah123"
      asset.descMetadata.lcsubject = [lcsubj]
      asset.descMetadata.lcsubject.first.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("anime", :language => :en))
      asset.descMetadata.lcsubject.first.persist!
      asset.descMetadata.rights = [rights]
      asset.descMetadata.rights.first.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("Attribution-NonCommercial-NoDerivatives 4.0 International", :language => :en))
      asset.descMetadata.rights.first.persist!
      asset.descMetadata.earliestDate = "1982"
      asset.descMetadata.latestDate = "1983"
      asset.descMetadata.format = [mtype]
      asset.descMetadata.format.first.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("image/tiff"))
      asset.descMetadata.format.first.persist!
      asset.descMetadata.location = [geo]
      asset.descMetadata.location.first.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("Eugene >> Lane County >> Oregon >> United States", :language => :en))
      asset.descMetadata.location.first.persist!
      asset.descMetadata.findingAid = [find]
      pset.title = "my set"
      pset.descMetadata.institution = RDF::URI.new("http://dbpedia.org/resource/University_of_Oregon")
      pset.descMetadata.institution.first.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("University of Oregon"))
      pset.save
      pset.review!
      asset.descMetadata.set = [pset]
      asset.descMetadata.primarySet = [pset]
      asset.save
      asset.review!
    end

    context "and they are generic assets" do
      before :each do
        visit oai_path(:verb => "ListRecords", :metadataPrefix => parameter)
      end
      it "should show them" do
        expect(page).to have_content("Test Title")
      end
      it "should return a label instead of a uri" do
        expect(page).to have_content("Hisaishi")
        expect(page).not_to have_content("http://id.loc.gov/authorities/names/no00013511")
      end
      it "should not display controlled field if it doesn't have a label" do
        expect(page).not_to have_xpath('//contributor')
      end
      it "should handle multiple values for a given field" do
        expect(page).to have_content("Hisaishi")
        expect(page).to have_content("Miyazaki")
      end
      it "should separate multiple values with a semicolon" do
        expect(page).to have_content("Miyazaki, Hayao, 1942-; Hisaishi, Joe")
      end
      it "should include OD access url and no other identifiers" do
        expect(page).to have_content("http://oregondigital.org/catalog/" + asset.pid)
        expect(page).not_to have_content("blahblah123")
      end
      it "should have the primarySet in the header identifier" do
        id = asset.pid.gsub("oregondigital:","")
        prefix = APP_CONFIG["oai"]["record_prefix"]
        expect(page).to have_selector('header/identifier',text: "#{prefix}:myset/#{id}")
      end
      #note that can't look for dc:lcsubject because nokogiri doesn't recognize the namespace
      it "should use the mapped_field if there is one" do
        expect(page).not_to have_xpath('//lcsubject')
      end
      it "should have earliest/latest date in the date field" do
        expect(page).to have_content("1982-1983")
      end
      it "should have only the rights url" do
        expect(page).not_to have_content("Attribution-NonCommercial-NoDerivatives 4.0 International")
        expect(page).to have_content("http://creativecommons.org/licenses/by-nc-nd/4.0/")
      end
      it "should have a format label" do
        expect(page).to have_content("image/tiff")
      end
      it "should have a location label with commas, not angle brackets" do
        expect(page).to have_content("Eugene, Lane County, Oregon, United States")
      end
      it "should have the string url for isReferencedBy" do
        expect(page).to have_content("http://blahblah.org")
      end
      it "should have the set label in isPartOf" do
        if parameter == 'oai_qdc'
         expect(page).to have_xpath('//ispartof', :text => "my set", :visible => true)
        end
      end
    end

    context "if one of them is deleted" do
      before do
        asset.soft_destroy
        asset.save
        visit oai_path(:verb => "ListRecords", :metadataPrefix => parameter)
      end
      it "should have 'deleted' in the header of the record" do
        expect(page).to have_xpath('//header[@status="deleted"]')
      end
    end
    context "when the asset's primaryset raises an error" do
      let(:pset2) {GenericCollection.new(pid:"oregondigital:myset2") }
      let(:asset2) {asset_class.new}
      before do
        asset2.title = "asset 2"
        asset2.descMetadata.primarySet = pset2
        asset2.descMetadata.set = pset2
        asset2.save
        asset2.review!
        visit oai_path(:verb => "ListRecords", :metadataPrefix => parameter)
      end
      #pset2 not saved with title, raises a NoMethodError when asked for an id
      it "shouldn't be included in the results" do
        expect{asset2.descMetadata.primarySet.first.id}.to raise_error
        expect(page).not_to have_content(asset2.id)
      end
    end

    context "and they are documents" do
      let(:asset_class) {Document}
      before do
        visit oai_path(:verb => "ListRecords", :metadataPrefix => parameter)
      end
      it "should show them" do
        expect(page).to have_content("Test Title")
      end
    end

    context "and they are not reviewed" do
      before do
        asset.reset_workflow!
        visit oai_path(:verb => "ListRecords", :metadataPrefix => parameter)
      end
      it "should not show them" do
        expect(page).not_to have_content("Test Title")
      end
    end
    context "when the verb is list sets" do
      before do
        visit oai_path(:verb => "ListSets")
      end

      it "should show any set that is a primary set" do
        expect(page).to have_content(pset.title)
      end
      it "should have the description for the set" do
        expect(page).to have_content(pset.descMetadata.institution.first.rdf_label.first)
      end
    end
  end
end

describe "Dublin Core response" do
  it_behaves_like "OAI endpoint", "oai_dc"
end

describe "Qualified Dublin Core response" do
  it_behaves_like "OAI endpoint", "oai_qdc"
end
