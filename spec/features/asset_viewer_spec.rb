require "spec_helper"

# Tests the asset viewers for various types of asset
describe "Asset viewer logic" do
  before(:each) do
    visit root_path
  end

  it "should use the small image viewer for small images" do
    image = FactoryGirl.create(:image, title: "Small image")
    click_button "Search"
    click_link "Small image"
    expect(page).to have_selector("#small-image-viewer > img[src$='#{image.pid}']")
  end

  it "should use the large image viewer for large images" do
    FactoryGirl.create(:image, title: "Use iip for this")
    click_button "Search"
    click_link "Use iip for this"
    expect(page).to have_selector("#large-image-viewer")
  end

  it "should use the document viewer for documents" do
    FactoryGirl.create(:document, title: "Some Doc")
    click_button "Search"
    click_link "Some Doc"
    expect(page).to have_selector("#document-viewer")
  end

  it "should use the generic viewer for all unknown assets" do
    FactoryGirl.create(:generic_asset, title: "Generic thingy")
    click_button "Search"
    click_link "Generic thingy"
    expect(page).to have_selector("#generic-viewer")
  end
end
