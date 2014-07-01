require 'spec_helper'

describe "compound objects" do
  let(:parent) {FactoryGirl.create(:generic_asset)}
  let(:object) {FactoryGirl.create(:generic_asset)}
  let(:object_2) {FactoryGirl.create(:generic_asset)}
  context "when an object is compound" do
    before do
      parent.od_content << object
      parent.od_content << object_2
      parent.save
    end
    context "and the root page is visited" do
      before do
        visit catalog_path(parent.pid)
      end
      context "and it has no content" do
        it "should redirect to the first item page" do
          expect(current_path).to eq catalog_path(object.pid)
        end
      end
      context "and it has content" do
        let(:parent) {FactoryGirl.create(:generic_asset, :with_tiff_datastream)}
        it "should not redirect" do
          expect(current_path).not_to eq catalog_path(object.pid)
          expect(current_path).to eq catalog_path(parent.pid)
        end
        it "should show a link to the root item in contents" do
          within("#contents") do
            expect(page).to have_content(parent.title)
          end
        end
      end
    end
    context "and the page is visited" do
      before do
        visit catalog_path(object.pid)
      end
      it "should show a table of contents" do
        expect(page).to have_content("Contents")
        expect(page).to have_content(object_2.title)
      end
      it "should not have a link to the current item" do
        expect(page).not_to have_link(object.title)
      end
      it "should have a working link to other items" do
        click_link object_2.title
        expect(current_path).to eq catalog_path(object_2.pid)
      end
    end
  end
end
