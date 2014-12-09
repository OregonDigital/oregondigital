require "spec_helper"

describe Ingest::AssetFileAttacher do
  # Why use a real uploader?  That class contains core magic the attacher
  # relies on (mimetype detection), and doesn't have its own isolated testing.
  # It's also a very simple class.  I'm also lazy.
  let(:upload) { IngestFileUpload.new }

  before(:each) do
    upload.file = File.new(upload_path(:jpg))
  end

  describe ".call" do
    let(:asset) { double("asset") }
    let(:file) { double("file") }
    let(:afa) { Ingest::AssetFileAttacher.new(asset, file) }

    before(:each) do
      Ingest::AssetFileAttacher.stub(:new => afa)
      afa.stub(:attach_file_to_asset)
    end

    it "instantiates a new object and calls attach_file_to_asset" do
      expect(Ingest::AssetFileAttacher).to receive(:new).with(asset, file).and_return(afa)
      expect(afa).to receive(:attach_file_to_asset)
      Ingest::AssetFileAttacher.call(asset, file)
    end

    it "returns the modified asset" do
      expect(Ingest::AssetFileAttacher.call(asset, file)).to eq(asset)
    end
  end

  describe "#attach_file_to_asset" do
    let(:asset) { instance_double("GenericAsset") }
    let(:content) { double("content datastream") }
    let(:attacher) { Ingest::AssetFileAttacher.new(asset, upload) }

    before(:each) do
      asset.stub(:content => content)
      content.stub(:content=)
      content.stub(:dsLabel=)
      content.stub(:mimeType=)

      # This is tested in detail below, but doesn't really belong in these
      # higher-level tests if we hope to extract this functionality someday
      attacher.stub(:transmogrify_asset)
    end

    it "should assign the file's contents" do
      expect(content).to receive(:content=).with(upload.file.read)
      attacher.attach_file_to_asset
    end

    it "should assign the filename as the datastream label" do
      expect(content).to receive(:dsLabel=).with("fixture_image.jpg")
      attacher.attach_file_to_asset
    end

    it "should set the mime type on the datastream" do
      expect(content).to receive(:mimeType=).with("image/jpeg")
      attacher.attach_file_to_asset
    end

    it "should transmogrify the asset into an Image" do
      expect(attacher).to receive(:transmogrify_asset).with(Image)
      attacher.attach_file_to_asset
    end
  end

  # This private method is tested separately because eventually we hope to move
  # this logic into AF
  describe "#transmogrify_asset" do
    let(:asset) { FactoryGirl.create(:generic_asset, title: "Testing stuffs") }
    let(:attacher) { Ingest::AssetFileAttacher.new(asset, upload) }

    it "should change @asset into an instance of the given class" do
      expect(attacher.asset).to be_kind_of(GenericAsset)
      attacher.send(:transmogrify_asset, Document)
      expect(attacher.asset).to be_kind_of(Document)
    end

    it "shouldn't add new relationships" do
      expect { attacher.send(:transmogrify_asset, Document) }.not_to change { attacher.asset.relationships.count }
    end

    it "should replace the hasModel relationship" do
      old_rel_json = attacher.asset.relationships.to_json
      attacher.send(:transmogrify_asset, Document)
      new_rel_json = attacher.asset.relationships.to_json

      expect(new_rel_json).to eq(old_rel_json.sub("GenericAsset", "Document"))
    end
  end
end
