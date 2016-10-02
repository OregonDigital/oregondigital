require 'spec_helper'

describe "Static Pages" do

  context "Copyright" do
    before(:each) do
      visit '/copyright'
    end
    it "should have the header 'Copyright, Access, and Use'" do
      expect(page).to have_content('Copyright, Access, and Use')
    end
  end

  context "Controlled Vocabularies" do
    before(:each) do
      visit '/controlled_vocabularies'
    end
    it "should include OregonDigital::ControlledVocabularies::Creator" do
      expect(page).to have_content('OregonDigital::ControlledVocabularies::Creator')
    end
    it "should not include GenericCollection" do
      expect(page).not_to have_content('GenericCollection')
    end
    it "should not include GenericAsset" do
      expect(page).not_to have_content('GenericAsset')
    end
  end
end
