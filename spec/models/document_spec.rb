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
        expect(document.content).not_to be_blank
        OregonDigital::FileDistributor.any_instance.stub(:base_path).and_return(Rails.root.join("media","test"))
        document.save
        document.create_derivatives
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
          expect(document.datastreams["page-#{page}"].content).to be_nil
          expect(document.datastreams["page-#{page}"].dsLocation).to eq "file://#{document.pages_location}/page-#{page}.png"
        end
      end
    end
  end
end
