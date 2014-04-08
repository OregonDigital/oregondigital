require 'spec_helper'

describe GenericCollection do
  it_behaves_like 'a collection'
  it_behaves_like 'a Questioning Authority interface'
  subject {FactoryGirl.build(:generic_collection)}

  describe '#resource' do
    before do
      subject.title = "bla"
    end
    it "should be a controlled vocabulary" do
      expect(subject.resource).to be_kind_of OregonDigital::ControlledVocabularies::Set
    end
    it "should not override other assets' resource classes" do
      expect(subject.resource).to be_kind_of OregonDigital::ControlledVocabularies::Set
      expect(GenericAsset.new.resource).not_to be_kind_of OregonDigital::ControlledVocabularies::Set
    end
    it "should be able to be saved" do
      expect{subject.save}.not_to raise_error
    end
    it "should create a URI on save" do
      subject.save
      expect(subject.resource.rdf_subject.to_s).to start_with "http://oregondigital.org/resource/"
    end
    it "should have an insitution attribute" do
      expect(subject).to respond_to :institution
    end
  end
end
