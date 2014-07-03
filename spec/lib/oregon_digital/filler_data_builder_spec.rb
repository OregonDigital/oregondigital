require 'spec_helper'

describe OregonDigital::FillerDataBuilder do
  subject {OregonDigital::FillerDataBuilder}
  let(:arguments) {}
  describe "#call" do
    before do
      subject.call(arguments)
    end
    context "when given no arguments" do
      describe "created collections" do
        let(:collections) {GenericCollection.all}
        before do
          Image.stub(:create_derivatives)
          Document.stub(:create_derivatives)
        end
        it "should create two" do
          expect(collections.length).to eq 2
        end
        it "should assign two different institutions" do
          expect(collections.first.institution).to eq [OregonDigital::ControlledVocabularies::Organization.new("University_of_Oregon")]
          expect(collections.last.institution).to eq [OregonDigital::ControlledVocabularies::Organization.new("Oregon_State_University")]
        end
        it "should create 3 images" do
          expect(Image.all.length).to eq 3
        end
        it "should create 3 documents" do
          expect(Image.all.length).to eq 3
        end
        it "should have items with content" do
          expect(Image.first.content).not_to be_blank
        end
      end
    end
  end
end
