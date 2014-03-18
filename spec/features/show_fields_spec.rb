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
    it "should show it" do
      expect(page).to have_content("Known Title")
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
        I18n.stub(:t).and_call_original
        I18n.stub(:t).with("oregondigital.catalog.show.title", {:default => "Title"}).and_return("Test Title")
      end
      it "should display it" do
        expect(page).to have_content("Test Title")
      end
    end
  end
end
