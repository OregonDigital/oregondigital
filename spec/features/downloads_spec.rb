require "spec_helper"

# Tests the basic properties of the download system
#
# TODO: Test this properly when we have more of the system built!  It should click to get to the
# downloads, not just visit the URL directly.
describe "Downloads" do
  let(:image) { image = FactoryGirl.create(:image, :with_jpeg_datastream) }
  let(:document) { document = FactoryGirl.create(:document, :with_pdf_datastream) }
  before do
    image.create_derivatives
  end

  describe "Visit download location directly" do
    context "(when the user has permission)" do
      let(:user) { FactoryGirl.create(:admin) }
      before do
        capybara_login(user)
      end
      it "should redirect" do
        visit download_path(:id => image.pid)
        expect(page.current_path).to eq "/media/medium-images/#{image.decorate.relative_medium_image_location}"
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
