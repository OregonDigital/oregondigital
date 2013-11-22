require 'spec_helper'

describe Datastream::OregonResource do
  before(:each) do
    class DummyAsset < ActiveFedora::Base
      has_metadata :name => 'descMetadata', :type => Datastream::OregonResource
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyAsset") if Object
  end
  subject {DummyAsset.new}
  describe "attribute setting" do
    before(:each) do
      subject.descMetadata.title = "bla"
    end
    it "should let you access the attribute" do
      expect(subject.descMetadata.title).to eq ["bla"]
    end
    context "after it is persisted" do
      before(:each) do
        subject.save
        subject.reload
      end
      it "should be accessible after being saved" do
        expect(subject.descMetadata.title).to eq ["bla"]
      end
      it "should serialize to content" do
        expect(subject.descMetadata.title).not_to be_blank
      end
    end
  end
end