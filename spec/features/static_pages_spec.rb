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

end
