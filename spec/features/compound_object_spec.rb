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
        it "should show its metadata" do
          expect(current_path).not_to eq catalog_path(object.pid)
          expect(current_path).to eq catalog_path(parent.pid)
          expect(page).to have_content(parent.title)
        end
        it "should not show the OD content in metadata" do
          expect(page).not_to have_content("Od content")
        end
        it "should show a link to the root item in contents" do
          within("#contents") do
            expect(page).to have_content(parent.title)
          end
        end
        it "should show a link to child items" do
          expect(page).to have_link object.title
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
    it "should not ask Fedora" do
      expect(parent.inner_object.class.any_instance).not_to receive(:datastream_dissemination)
      expect(GenericAsset).not_to receive(:from_uri)
      visit catalog_path(parent.pid)
      expect(page).to have_link object.title
      visit catalog_path(object.pid)
      expect(page).to have_link parent.title
    end
    context "and the object has a compound node title" do
      before do
        t = object.title
        parent.od_content.first.title = "Test Compound Node Title"
        parent.save
        expect(object.reload.title).to eq t
        visit catalog_path(parent.pid)
      end
      it "should show that as the link" do
        expect(page).to have_link("Test Compound Node Title")
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
      it "should have a working link to the root item" do
        click_link parent.title
        expect(current_path).to eq catalog_path(parent.pid)
      end
    end
  end
end
