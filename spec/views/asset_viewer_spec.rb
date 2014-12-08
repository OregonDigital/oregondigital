require 'spec_helper'

describe "object views" do
  before do
    asset.object.stub(:pid).and_return("oregondigital:bla")
  end
  describe "catalog/_small_image_viewer.html.erb" do
    let(:asset) { FactoryGirl.build(:image).decorate }
    it "should have a basic image tag" do
      render "catalog/small_image_viewer", :decorated_object => asset
      expect(rendered).to have_selector("#small-image-viewer > img[src$='#{asset.pid.gsub(':', '-')}.jpg']")
    end
  end

  describe "catalog/_large_image_viewer.html.erb" do
    let(:asset) { FactoryGirl.build(:image).decorate }
    it "should use the large image viewer for large images" do
      render "catalog/large_image_viewer", :decorated_object => asset
      expect(rendered).to have_selector("#large-image-viewer")
    end
  end
  
  describe "catalog/_document_viewer.html.erb" do
    let(:asset) { FactoryGirl.build(:document).decorate }
    it "should display a document viewer" do
      render "catalog/document_viewer", :decorated_object => asset
      expect(rendered).to have_selector("#document-viewer")
    end
  end

  describe "catalog/_generic_viewer.html.erb" do
    let(:asset) { FactoryGirl.build(:generic_asset).decorate }
    it "should display a generic viewer" do
      render "catalog/generic_viewer", :decorated_object => asset
      expect(rendered).to have_selector("#generic-viewer")
    end
  end

  describe "catalog/_video_viewer.html.erb" do
    let(:asset) { FactoryGirl.build(:video).decorate }
    it "should display a video viewer" do
      render "catalog/video_viewer", :decorated_object => asset
      expect(rendered).to have_selector("video")
    end
  end

  describe "catalog/_audio_viewer.html.erb" do
    let(:asset) { FactoryGirl.build(:audio).decorate }
    it "should display a audio viewer" do
      render "catalog/audio_viewer", :decorated_object => asset
      expect(rendered).to have_selector("audio")
    end
  end
end
