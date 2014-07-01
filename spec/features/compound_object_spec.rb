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
