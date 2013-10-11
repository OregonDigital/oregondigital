require "spec_helper"

# Tests the basic properties of the download system
#
# TODO: Test this properly when we have more of the system built!  It should click to get to the
# downloads, not just visit the URL directly.
describe "Downloads" do
  let(:image_fixture) do
    File.open(fixture_path + "/fixture_image.jpg", "rb").read
  end

  let(:pdf_fixture) do
    File.open(fixture_path + "/fixture_pdf.pdf", "rb").read
  end

  let(:image) do
    image = Image.new
    image.add_file_datastream(image_fixture, dsid: "content", mimeType: "image/jpeg", label: "large.jpg")
    image.review
    image.read_groups = ["public"]
    image.save
    image
  end

  let(:document) do
    document = Document.new
    document.add_file_datastream(pdf_fixture, dsid: "content", mimeType: "application/pdf", label: "doc.pdf")
    document.review
    document.read_groups = ["public"]
    document.save
    document
  end

  describe "Visit download location directly" do
    context "(when the user has permission)" do
      it "should give us the proper image file" do
        visit download_path(:id => image.pid)
        page.response_headers['Content-Type'].should eq "image/jpeg"
        page.response_headers['Content-Length'].should eq image_fixture.length.to_s
      end

      it "should give us the proper pdf file" do
        visit download_path(:id => document.pid)
        page.response_headers['Content-Type'].should eq "application/pdf"
        page.response_headers['Content-Length'].should eq pdf_fixture.length.to_s
      end
    end

    context "(when the user does not have permission)" do
      before(:each) do
        image.read_groups = []
        image.save
      end
      it "should fail if the user does not have access" do
        expect{visit download_path(:id => image.pid)}.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
