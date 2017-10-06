require 'spec_helper'

describe "ThumbnailsController" do

  let(:url) {"#{APP_CONFIG['default_url_host']}/thumbnails/oregondigital-1r2t3y4u.jpg"}
  describe "thumbnail_links" do
    it "should parse correct path to thumb and redirect" do
      visit(url)
      expect(current_path).to include("/media/thumbnails/u/4/oregondigital-1r2t3y4u.jpg")
    end
  end
end
