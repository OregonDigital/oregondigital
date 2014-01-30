shared_examples 'an ingest controller uploader' do |action|
  let(:file) do
    OpenStruct.new(
      read: "contents",
      filename: "filename",
      file: OpenStruct.new(:content_type => "image/tiff")
    )
  end

  # Use strings everywhere to ensure it's just like a Rails form submission
  let(:params) do
    {
      "id" => "1",
      metadata_ingest_form: {
        "titles_attributes" => {
          "0" => {"type" => "title", "value" => "test title", "internal" => "", "_destroy" => "false"}
        },
      },
      "upload" => "foo",
      "upload_cache" => "bar"
    }
  end

  let(:asset) { GenericAsset.new }

  before(:each) do
    # Stub resources so we can make assertions on what the controller sees, avoid AF hits, etc
    case action
      when :create then GenericAsset.stub(:new => asset)
      when :update then GenericAsset.stub(:find).with("1").and_return(asset)
    end
    asset.stub(:save)
    asset.stub(:save!)

    # Make sure we don't create a new asset that hits AF and does lovely things
    # like running derivatives
    asset.stub(:adapt_to).and_return(asset)

    @upload = IngestFileUpload.new
    IngestFileUpload.stub(:new).and_return(@upload)
    @upload.stub(:file=)
    @upload.stub(:file_cache=)
    @upload.stub(:file => file)
  end

  it "should set up the @upload object" do
    expect(@upload).to receive(:file=).with(params["upload"])
    expect(@upload).to receive(:file_cache=).with(params["upload_cache"])
    post action, params
  end

  it "should save the file to the asset's content datastream" do
    expect(file).to receive(:process!)
    expect(asset.content).to receive(:content=).with("contents")
    expect(asset.content).to receive(:dsLabel=).with("filename")
    expect(asset.content).to receive(:mimeType=).with("image/tiff")
    asset.should_receive(:save)

    post action, params
  end

  it "shouldn't alter the existing file if a new file wasn't uploaded" do
    expect(file).not_to receive(:process!)
    expect(asset.content).not_to receive(:content=)
    expect(asset.content).not_to receive(:dsLabel=)
    expect(asset.content).not_to receive(:mimeType=)
    asset.should_receive(:save)

    params.delete("upload")
    params.delete("upload_cache")
    post action, params
  end

  it "should switch to an Image class" do
    expect(asset).to receive(:adapt_to).with(Image).once.and_return(asset)
    post action, params
  end
end
