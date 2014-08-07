require 'spec_helper'

describe OregonDigital::OCR::BookreaderSearchGenerator do
  let(:document) do
    d = FactoryGirl.create(:document, :with_pdf_datastream)
    d.create_derivatives
    d
  end
  let(:query) {"dog"}
  describe "#call" do
    subject {OregonDigital::OCR::BookreaderSearchGenerator.call(document, query)}
    context "when called with a query" do
      it "should return multiple pages of matches" do
        expect(subject[:matches].length).to eq 2
      end
      it "should return multiple boxes" do
        expect(subject[:matches].inject(0){|sum, hsh| sum += hsh[:par][0][:boxes].length}).to eq 10
      end
    end
  end

end
