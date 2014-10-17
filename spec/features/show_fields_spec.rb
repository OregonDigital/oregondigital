require 'spec_helper'

describe "show fields" do
  let(:asset) {FactoryGirl.create(:generic_asset)}
  let(:stub_setup) {nil}
  before(:each) do
    stub_setup
    visit catalog_path(asset.pid)
  end
  context "when it has a title" do
    let(:asset) do
      FactoryGirl.create(:generic_asset, :title => "Known Title")
    end
    let(:stub_setup) do
      asset
      expect(asset.inner_object.repository).not_to receive(:datastream_dissemination)
    end
    it "should show it" do
      expect(page).to have_content("Known Title")
    end
  end
  context "when it has a field with a subject" do
    let(:subject) {RDF::URI.new("http://id.loc.gov/authorities/subjects/sh85050282")}
    let(:asset) do
      g = FactoryGirl.build(:generic_asset)
      g.descMetadata.lcsubject = subject
      g.save
      g
    end
    context "which is a URI" do
      let(:stub_setup) {GenericAsset.any_instance.stub(:queue_fetch).and_return(true)}
      it "should not have an RDF label" do
        expect(asset.descMetadata.lcsubject.first.rdf_label.first).to eq subject.to_s
      end
      it "should pretend the subject field is empty" do
        expect(page).not_to have_content("subject")
      end
      it "should not show URI subjects" do
        expect(page).not_to have_content(subject.to_s)
      end
    end
    context "which has an rdf_label set up" do
      let(:asset) do
        g = FactoryGirl.build(:generic_asset)
        g.descMetadata.lcsubject = subject
        g.descMetadata.lcsubject.first.set_value(RDF::SKOS.prefLabel, RDF::Literal.new("Test Subject", :language => :en))
        g.descMetadata.lcsubject.first.persist!
        g.save
        g
      end
      it "should have an RDF label" do
        expect(asset.lcsubject.first.rdf_label.first).to eq "Test Subject"
      end
      it "should show it" do
        expect(page).to have_content("Test Subject")
      end
    end
  end
  context "when it has data in descMetadata" do
    let(:asset) do
      g = FactoryGirl.build(:generic_asset)
      g.descMetadata.photographer = "Test Photographer"
      g.save
      g
    end
    it "should show it" do
      expect(page).to have_content("Test Photographer")
    end
    context "and a label is configured" do
      let(:stub_setup) do
        I18n.backend.send(:translations)[:en][:oregondigital][:metadata][:title] = "Test Title"
      end
      it "should display it" do
        expect(page).to have_content("Test Title")
      end
    end
  end
end
