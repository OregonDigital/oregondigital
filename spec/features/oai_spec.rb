require 'spec_helper'

shared_examples "OAI endpoint" do |parameter|
  let(:asset_class) {GenericAsset}

  context "when there are assets" do
    let(:lcname) {RDF::URI.new("http://id.loc.gov/authorities/names/nr93013379")}
    let(:lcname2) {RDF::URI.new("http://id.loc.gov/authorities/names/no00013511")}
    let(:lcsubj) {RDF::URI.new("http://id.loc.gov/authorities/subjects/sh2003003075")}
    let(:rights) {RDF::URI.new("http://creativecommons.org/licenses/by-nc-nd/4.0/")}
    let(:opns) {RDF::URI.new("http://opaquenamespace.org/ns/creator/mylittlecreator")}
    let(:pset) {GenericCollection.new(pid:"oregondigital:myset")}
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
      pset.title = "my set"
      pset.save
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
      it "should include OD url and  any other identifiers" do
        expect(page).to have_content("http://oregondigital.org/catalog/" + asset.pid)
        expect(page).to have_content("blahblah123")
        #expect(page).to have_content("oai:oregondigital.org:myset/" + asset.pid.gsub("oregondigital:",""))
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
      it "should have both the rights url and the rights label" do
        expect(page).to have_content("Attribution-NonCommercial-NoDerivatives 4.0 International")
        expect(page).to have_content("http://creativecommons.org/licenses/by-nc-nd/4.0/")
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
  end
end

describe "Dublin Core response" do
  it_behaves_like "OAI endpoint", "oai_dc"
end

describe "Qualified Dublin Core response" do
  it_behaves_like "OAI endpoint", "oai_qdc"
end
