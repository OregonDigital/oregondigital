require 'spec_helper'

describe 'soft delete' do
  let(:user) {FactoryGirl.create(:user)}
  let(:asset) {FactoryGirl.create(:image)}
  before do
    capybara_login(user)
    asset
    visit catalog_path(:id => asset.pid)
  end
  context "when a user is an admin" do
    let(:user) {FactoryGirl.create(:admin)}
    it "should show a destroy button" do
      expect(page).to have_link("Delete")
    end
    context "and the destroy button is clicked" do
      before do
        click_link "Delete"
        within("#main-flashes") do
          expect(page).to have_content("Successfully deleted asset.")
        end
      end
      it "should not really delete the asset" do
        expect(Image.find(asset.pid).pid).to eq asset.pid
      end
      it "should not show the asset on search results" do
        visit root_path(:search_field => "all_fields")
        expect(page).not_to have_selector(".document")
      end
      
    end
  end
end
