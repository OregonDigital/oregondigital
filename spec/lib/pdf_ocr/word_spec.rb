describe PdfOcr::Word do
  context "when given a word node" do
    subject {PdfOcr::Reader.new(content).pages.first.words.first}
    let(:content) {File.read(Rails.root.join("spec", "fixtures", "fixture_text.html"))}
    
    describe "#xmin" do
      it "should return xmin" do
        expect(subject.xmin).to eq 171.317902
      end
    end

    describe "#xmax" do
      it "should return xmax" do
        expect(subject.xmax).to eq 201.030900
      end
    end

    describe "#ymin" do
      it "should return ymin" do
        expect(subject.ymin).to eq 31.767395
      end
    end
    
    describe "#ymax" do
      it "should return ymax" do
        expect(subject.ymax).to eq 47.616500
      end
    end

    describe "#page" do
      it "should return the parent page" do
        expect(subject.page.document.to_s).to eq PdfOcr::Reader.new(content).pages.first.document.to_s
      end
    end

    describe "#text" do
      it "should return the text of the word" do
        expect(subject.text).to eq "sier!"
      end
    end
  end
end

