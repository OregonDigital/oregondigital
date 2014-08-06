require 'spec_helper' do

end
describe Document do
  subject(:document) {Document.new}

  it "should instantiate" do
    expect{document}.not_to raise_error
  end

  describe "derivatives" do
    context "when a document has content" do
      before(:each) do
        file = File.open(File.join(fixture_path, 'fixture_pdf.pdf'), 'rb')
        document.add_file_datastream(file, :dsid => 'content')
        OregonDigital::FileDistributor.any_instance.stub(:base_path).and_return(Rails.root.join("media","test"))
        document.save
        document.create_derivatives
        document
      end
      after(:each) do
        begin
          FileUtils.rm_rf(Rails.root.join("media","test"))
        rescue
        end
      end
      it "should create a derivative per page" do
        (1..2).each do |page|
          expect(document.datastreams.keys).to include("page-#{page}")
          expect(document.datastreams["page-#{page}"].dsLocation).to eq "file://#{document.pages_location}/normal-page-#{page}.jpg"
          expect(Document.find(document.pid).datastreams.keys).to include("page-#{page}")
        end
      end
      it "should create an OCR document" do
        expect(document.content_ocr.content).not_to be_blank
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(document.ocr_location.to_s).split(';')[0]
        expect(mime_type).to eq 'text/html'
      end
      it "should create a thumbnail" do
        expect(document.datastreams["page-1"].content).not_to be_blank
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(document.thumbnail_location).split(';')[0]
        expect(mime_type).to eq 'image/jpeg'
      end
      it 'should populate the external thumbnail datastream' do
        expect(document.thumbnail.dsLocation).to eq("file://#{document.thumbnail_location}")
        expect(Image.find(document.pid).thumbnail.dsLocation).to eq("file://#{document.thumbnail_location}")
      end
    end
  end
end
