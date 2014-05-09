require 'spec_helper'

describe "fun functionality" do
  let(:asset) {GenericAsset.new}
  context "when content is set" do
    before(:each) do
      asset.title = "Test Title"
    end
    it "should return" do
      expect(asset.title).to eq "Test Title"
    end
    context "after it is saved" do
      before(:each) do
        asset.save
      end
      it "should maintain that data" do
        a = GenericAsset.find(asset.pid)
        expect(a.title).to eq "Test Title"
      end
      it "should work on reload" do
        asset.reload
        expect(asset.title).to eq "Test Title"
      end
      it "should not call datastream content" do
        asset.reload
        expect(asset.descMetadata).not_to receive(:datastream_content)
        expect(asset.title).to eq "Test Title"
      end
    end
  end
end
