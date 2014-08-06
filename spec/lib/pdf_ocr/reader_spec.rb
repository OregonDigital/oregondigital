require 'spec_helper'

describe PdfOcr::Reader do
  context "when given a PDF" do
    subject {PdfOcr::Reader.new(content)}
    let(:content) {File.read(Rails.root.join("spec", "fixtures", "fixture_text.html"))}

    describe '#pages' do
      it "should return two pages" do
        expect(subject.pages.length).to eq 2
        expect(subject.pages.first).to be_kind_of PdfOcr::Page
      end
    end

    describe '#words' do
      it "should return words from all pages" do
        expect(subject.words.length).to eq subject.pages.reduce(0) {|sum, p| sum + p.words.length}
      end
    end
  end
end


