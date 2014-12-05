require 'spec_helper'

describe GenericAssetDecorator do
  let(:subject) {GenericAssetDecorator.new(asset)}
  let(:asset) {FactoryGirl.build(:generic_asset)}
  let(:result) {subject.sorted_show_fields}

  describe "#view_partial" do
    let(:asset) { inner.decorate }
    context "an image with jpeg content" do
      let(:inner) { FactoryGirl.build(:image, :with_jpeg_datastream) }
      it "should be small image viewer" do
        expect(asset.view_partial).to eq "small_image_viewer"
      end
    end
    context "an image with a large tiff" do
      let(:inner) { FactoryGirl.build(:image, :with_tiff_datastream) }
      it "should be large image viewer" do
        expect(asset.view_partial).to eq "large_image_viewer"
      end
    end
    context "a document" do
      let(:inner) { FactoryGirl.build(:document) }
      it "should be document viewer" do
        expect(asset.view_partial).to eq "document_viewer"
      end
    end
    context "a generic asset" do
      let(:inner) { FactoryGirl.build(:generic_asset) }
      it "should be a generic viewer" do
        expect(asset.view_partial).to eq "generic_viewer"
      end
    end
    context "an audio asset" do
      let(:inner) { FactoryGirl.build(:audio) }
      it "should be an audio viewer" do
        expect(asset.view_partial).to eq "audio_viewer"
      end
    end
    context "a video asset" do
      let(:inner) { FactoryGirl.build(:video) }
      it "should be an audio viewer" do
        expect(asset.view_partial).to eq "video_viewer"
      end
    end
  end

  describe "#sorted_show_fields" do
    before(:each) do
      I18n.stub(:t).and_call_original
    end

    context "when there is no configuration" do
      before(:each) do
        I18n.stub(:t).with("oregondigital.metadata").and_return({})
      end

      it "should return the keys with values" do
        expect(result).to eq ["title", "created"]
      end
      context "when a field has a value" do
        let(:asset) do
          g = FactoryGirl.build(:generic_asset)
          g.descMetadata.photographer = "Test Photographer"
          g
        end
        it "should return keys in the order they're defined in OregonRDF" do
          expect(result).to eq ["title", "photographer", "created"]
        end
      end
      context "when there is an I18n configuration for fields" do
        let(:asset) do
          g = FactoryGirl.build(:generic_asset)
          g.descMetadata.photographer = "Test Photographer"
          g
        end
        before(:each) do
          I18n.stub(:t).with("oregondigital.metadata").and_return({:photographer => "photographer", :created => "created"})
        end
        it "should organize those fields at the top in the given order" do
          expect(result).to eq ["photographer", "created", "title"]
        end
      end
    end
  end

end
