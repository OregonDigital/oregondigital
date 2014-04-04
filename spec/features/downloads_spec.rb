require "spec_helper"

# Tests the basic properties of the download system
#
# TODO: Test this properly when we have more of the system built!  It should click to get to the
# downloads, not just visit the URL directly.
describe "Downloads" do
  let(:image) { image = FactoryGirl.create(:image, :with_jpeg_datastream) }
  let(:document) { document = FactoryGirl.create(:document, :with_pdf_datastream) }

  describe "Visit download location directly" do
    context "(when the user has permission)" do
      it "should give us the proper image file" do
        visit download_path(:id => image.pid)
        headers = page.response_headers
        headers['Content-Type'].should eq "image/jpeg"
        headers['Content-Length'].should eq File.size(fixture_path + "/fixture_image.jpg").to_s
      end

      it "should give us the proper pdf file" do
        visit download_path(:id => document.pid)
        headers = page.response_headers
        headers['Content-Type'].should eq "application/pdf"
        headers['Content-Length'].should eq File.size(fixture_path + "/fixture_pdf.pdf").to_s
      end
    end

    context "(when the user does not have permission)" do
      before(:each) do
        image.read_groups = []
        image.save
      end
      it "should fail if the user does not have access" do
        visit download_path(:id => image.pid)
        expect(page).to have_content("You do not have sufficient access privileges to read this document")
      end
    end
  end
end
