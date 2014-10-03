require 'spec_helper'

describe OregonDigital::RDF::CompoundResource do
  subject {OregonDigital::RDF::CompoundResource.new(rdf_subject)}
  let(:rdf_subject) {RDF::Node.new}
  
  describe "#title" do
    before do
      subject.title = "Test"
    end
    it "should store title" do
      expect(subject.title).to eq ["Test"]
    end
  end

  describe "#references" do
    context "when given an image" do
      let(:image) {FactoryGirl.create(:image)}
      before do
        subject.references << image
      end
      it "should give it back" do
        expect(subject.references.first).to eq image
      end
      it "should fall back to references title" do
        expect(subject.title).to eq [image.title]
      end
      context "and the resource has a title" do
        before do
          subject.title = "Test"
        end
        it "should use that title instead" do
          expect(subject.title).to eq ["Test"]
        end
      end
    end
  end
end
