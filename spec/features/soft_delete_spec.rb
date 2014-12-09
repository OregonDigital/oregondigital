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
    context "and the item is already destroyed" do
      before do
        asset.soft_destroy
        visit catalog_path(:id => asset.pid)
      end
      it "should have a working Undelete button" do
        click_link "Undelete"
        expect(page).to have_content("restored")
        expect(asset.reload).not_to be_soft_destroyed
      end
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

describe 'Destroyed Objects View' do
  let(:user) {FactoryGirl.create(:user)}
  let(:asset) {FactoryGirl.create(:image)}
  before do
    capybara_login(user)
    asset
    visit destroyed_index_path
  end
  context"when a user is not an admin" do
    it "should not allow access" do
      expect(page).to have_content("You do not have permission to manage destroyed objects.")
    end
  end
  context "when a user is an admin" do
    let(:user) {FactoryGirl.create(:admin)}
    context "and there are no destroyed items" do
      it "should not show any items" do
        expect(page).not_to have_selector('.document')
      end
    end
    context "and there are destroyed items" do
      before do
        asset.soft_destroy
        visit destroyed_index_path
      end
      it "should show them" do
        expect(page).to have_selector('.document')
      end
      context "and the Undelete button is clicked" do
        before do
          click_link "Undelete"
          within("#main-flashes") do
            expect(page).to have_content("Successfully restored object.")
          end
        end
        it "should undelete the item" do
          expect(asset.reload).not_to be_soft_destroyed
        end
        it "should go to the show view" do
          expect(current_path).to eq catalog_path(:id => asset.pid)
        end
        it "should no longer show it" do
          visit destroyed_index_path
          expect(page).not_to have_selector('.document')
        end
      end
      context "and the item is unreviewed" do
        before do
          asset.reset_workflow!
          visit destroyed_index_path
        end
        it "should show it" do
          expect(page).to have_selector('.document')
        end
      end
    end
    context "and there are non-destroyed items" do
      it "should not show them" do
        expect(page).not_to have_selector('.document')
      end
    end
  end
end
