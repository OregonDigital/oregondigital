require 'spec_helper'

describe 'bookmarks', :js => true do
  let(:user) { FactoryGirl.create(:user) }
  let(:asset) { FactoryGirl.create(:generic_asset) }
  context "(with bookmarks)" do
    before(:each) do
      capybara_login(user)
      asset
      visit root_path(:search_field => "all_fields")
      expect(page).to have_selector("input[type='checkbox']")
      find("input[type='checkbox']").click
      expect(page).to have_content("In Bookmarks")
      visit bookmarks_path
    end
    it "should show all the bookmarks" do
      expect(page).to have_content(asset.title)
    end
    %w{Cite Refworks EndNote Email}.each do |button|
      it "should not show the #{button} button" do
        within(".bookmarkTools") do
          expect(page).not_to have_content(button)
        end
      end
    end
  end
end
