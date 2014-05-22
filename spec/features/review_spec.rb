require 'spec_helper'

describe "item review behavior" do
  before(:each) do
    capybara_login(user)
  end
  context "when logged in as a user" do
    let(:user) {FactoryGirl.create(:user)}
    context "on the review page" do
      before(:each) do
        visit reviewer_index_path
      end
      it "should not let them in" do
        expect(page).to have_content("You do not have permission to review.")
      end
    end
  end
  context "when logged in as an admin" do
    let(:user) {FactoryGirl.create(:admin)}

    context "when an item was just ingested" do
      before(:each) do
        visit_ingest_url
        fill_out_dummy_data
        click_the_ingest_button
        visit reviewer_index_path
      end

      it "should be visible in the list of reviewable assets" do
        expect(page).to have_selector('.document', :count => 1)
      end

      it "should have visible metadata" do
        click_link "Asset Title"
        expect(page).to have_content("Asset Title")
        expect(page).to have_content("2014-01-07")
      end
    end

    context "with an unreviewed item" do
      let(:asset) {FactoryGirl.create(:generic_asset, :pending_review)}
      before(:each) do
        asset
      end
      context "on the catalog page" do
        before(:each) do
          visit catalog_index_path(:search_field => 'all_fields')
        end
        it "should not show the item" do
          expect(page).not_to have_selector('.document')
        end
        it "should show a link to the review page" do
          expect(page).to have_link("Review")
        end
      end
      context "on the review page" do
        before(:each) do
          visit reviewer_index_path
        end
        context "when the item has a thumbnail" do
          let(:asset) do
            i = FactoryGirl.create(:image, :pending_review, :with_tiff_datastream)
            i.create_derivatives
          end
          it "should show the item" do
            expect(page).to have_selector(".document", :count => 1)
            expect(page).to have_selector(".document img[src^='/thumbnails']")
          end
        end
        it "should let them in" do
          expect(page).not_to have_content("You do not have permission to review.")
        end
        it "should show the item" do
          expect(page).to have_selector('.document', :count => 1)
        end
        context "when the item is soft destroyed" do
          before do
            asset.soft_destroy
            visit reviewer_index_path
          end
          it "should not show the item" do
            expect(page).not_to have_selector('.document')
          end
        end
        context "when they are no longer an admin and they try to review" do
          before(:each) do
            Role.destroy_all
          end
          it "should not allow them access" do
            click_button "Mark as Reviewed"
            expect(page).to have_content("You are not authorized to access this page.")
          end
        end
        context "when the mark as reviewed button is clicked" do
          before(:each) do
            click_button "Mark as Reviewed"
          end
          it "should mark the item as reviewed" do
            expect(page).to have_content('Successfully reviewed.')
            expect(GenericAsset.last).to be_reviewed
          end
          it "should be viewable on the catalog" do
            expect(page).to have_content('Successfully reviewed.')
            visit catalog_index_path
            click_button "search"
            expect(page).to have_selector(".document")
          end
        end
      end
    end

    context "with a template item" do
      before(:each) do
        FactoryGirl.create(:template)
        visit reviewer_index_path
      end
      it "should not show the item" do
        expect(page).not_to have_selector('.document')
      end
    end

    context "with a reviewed item" do
      before(:each) do
        FactoryGirl.create(:generic_asset)
      end
      context "on the catalog page" do
        before(:each) do
          visit catalog_index_path(:search_field => 'all_fields')
        end
        it "should show the item" do
          expect(page).to have_selector('.document', :count => 1)
        end
      end
      context "on the review page" do
        before(:each) do
          visit reviewer_index_path
        end
        it "should not show the item" do
          expect(page).not_to have_selector('.document')
        end
      end
    end
  end
end

describe '#reviewed' do
  before do
    10.times { FactoryGirl.create(:generic_asset) }
    FactoryGirl.create(:generic_asset, :pending_review)
  end
  it 'should return only reviewed items' do
    GenericAsset.reviewed.each do |i|
      expect(i.reviewed?).to eq true
    end
  end
  it 'should return all reviewed items' do
    reviewed = GenericAsset.reviewed
    GenericAsset.all do |i|
      if i.reviewed?
        expect(reviewed).to include i
      end
    end
  end
end
