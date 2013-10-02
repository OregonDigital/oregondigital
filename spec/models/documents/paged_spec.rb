require 'spec_helper' do

end
describe Documents::Paged do
  subject(:document) {Documents::Paged.new}

  it "should instantiate" do
    expect{document}.not_to raise_error
  end

  describe "derivatives" do
    context "when a document has content" do
      before(:each) do
        file = File.open(File.join(fixture_path, 'fixture_pdf.pdf'))
        document.add_file_datastream(file, :dsid => 'content')
        expect(document.content).not_to be_blank
        document.save
        document.create_derivatives
      end
      it "should create a set three sizes of derivative for each page" do
        %w{small normal large}.each do |size|
          (1..2).each do |page|
            expect(document.datastreams.keys).to include("#{size}-#{page}")
            expect(document.datastreams["#{size}-#{page}"].content).not_to be_nil
          end
        end
      end
    end
  end
end