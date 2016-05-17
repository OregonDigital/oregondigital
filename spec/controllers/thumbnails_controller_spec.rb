require 'spec_helper'

describe "ThumbnailsController" do

  let(:url) {"http://#{APP_CONFIG['default_host']}/thumbnails/oregondigital-1r2t3y4u.jpg"}
  describe "thumbnail_links" do
    it "should parse correct path to thumb and redirect" do
      visit(url)
      expect(current_path).to eq("#{APP_CONFIG['default_host']}/media/thumbnails/u/4/oregondigital-1r2t3y4u.jpg")
    end
  end
end
