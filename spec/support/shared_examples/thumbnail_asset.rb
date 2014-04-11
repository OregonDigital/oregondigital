shared_examples "a thumbnail asset" do 
  before(:each) do
    asset.create_derivatives
    visit root_path(:search_field => "all_field")
  end

  after(:each) do
    begin
      FileUtils.rm_rf(Rails.root.join("media","test"))
    rescue
    end
  end

  it "should show the thumbnail in search results", :js => true do
    expect(page).to have_selector(".document img")
    expect(page).to have_selector(".document img[src^='/thumbnails']")
  end

  it "should set an alt value on the thumbnail" do
    expect(page).to have_selector(".document img[src^='/thumbnails'][alt='#{asset.title}'][title='#{asset.title}']")
  end

  context "when the thumbnails are clicked" do
    it "should have clickable thumbnails", :js => true do
      expect(page).to have_selector(".document img[src^='/thumbnails']")
      find(".document img[src^='/thumbnails']").click
      expect(current_path).to eq catalog_path(:id => asset.pid)
    end
  end

end
