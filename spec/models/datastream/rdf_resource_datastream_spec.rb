require 'spec_helper'

describe Datastream::RdfResourceDatastream do
  before(:each) do
    class DummyResource < Datastream::RdfResourceDatastream
      property :title, :predicate => RDF::DC[:title], :class_name => RDF::Literal do |index|
        index.as :searchable, :displayable
      end
      def serialization_format
        :ntriples
      end
    end
    class DummyAsset < ActiveFedora::Base
      has_metadata :name => 'descMetadata', :type => DummyResource
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyAsset") if Object
    Object.send(:remove_const, "DummyResource") if Object
  end
  subject {DummyAsset.new}
  describe "attribute setting" do
    before(:each) do
      subject.descMetadata.title = "bla"
    end
    it "should let you access the attribute" do
      expect(subject.descMetadata.title).to eq ["bla"]
    end
    it "should mark it as changed" do
      expect(subject.descMetadata).to be_changed
    end
    context "after it is persisted" do
      before(:each) do
        subject.save
        subject.reload
      end
      context "and it's reloaded" do
        before(:each) do
          subject.reload
        end
        it "should be accessible after being saved" do
          expect(subject.descMetadata.title).to eq ["bla"]
        end
        it "should serialize to content" do
          expect(subject.descMetadata.content).not_to be_blank
        end
      end
      context "and it is found again" do
        before(:each) do
          @object = DummyAsset.find(subject.pid)
        end
        it "should serialize to content" do
          expect(@object.descMetadata.content).not_to be_blank
        end
        it "should be accessible after being saved" do
          expect(@object.descMetadata.title).to eq ["bla"]
        end
        it "should have datastream content" do
          expect(@object.descMetadata.datastream_content).not_to be_blank
        end
      end
    end
  end
end
