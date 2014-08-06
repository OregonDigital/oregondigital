describe PdfOcr::Page do
  context "when given a page" do
    subject {PdfOcr::Reader.new(content).pages.first}
    let(:content) {File.read(Rails.root.join("spec", "fixtures", "fixture_text.html"))}

    describe "#words" do
      it "should return words" do
        expect(subject.words.length).to eq 101
        expect(subject.words.first).to be_kind_of PdfOcr::Word
      end
    end

    describe "#width" do
      it "should return the width" do
        expect(subject.width).to eq 531.086990
      end
    end

    describe "#height" do
      it "should return the height" do
        expect(subject.height).to eq 665.950700
      end
    end

    describe "#page_number" do
      it "should return the page number" do
        expect(subject.page_number).to eq 1
        expect(PdfOcr::Reader.new(content).pages.last.page_number).to eq 2
      end
    end
  end
end
