require 'spec_helper'

describe Datastream::RdfResourceDatastream do
  before(:each) do
    class DummySubnode < OregonDigital::RdfResource
      property :title, :predicate => RDF::DC[:title], :class_name => RDF::Literal
    end
    class DummyResource < Datastream::RdfResourceDatastream
      property :title, :predicate => RDF::DC[:title], :class_name => RDF::Literal do |index|
        index.as :searchable, :displayable
      end
      property :license, :predicate => RDF::DC[:license], :class_name => DummySubnode do |index|
        index.as :searchable, :displayable
      end
      def serialization_format
        :ntriples
      end
    end
    class DummyAsset < ActiveFedora::Base
      has_metadata :name => 'descMetadata', :type => DummyResource
      delegate :title, :to => :descMetadata, :multiple => true
      delegate :license, :to => :descMetadata, :multiple => true
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyAsset") if Object
    Object.send(:remove_const, "DummyResource") if Object
  end
  subject {DummyAsset.new}
  describe "#to_solr" do
    before(:each) do
      subject.descMetadata.title = "bla"
      subject.descMetadata.license = DummySubnode.new('http://example.org/blah')
    end
    it "should not be blank" do
      expect(subject.to_solr).not_to be_blank
    end
    it "should solrize" do
      expect(subject.to_solr["desc_metadata__title_teim"]).to eq ["bla"]
    end
    it "should solrize uris" do
      expect(subject.to_solr["desc_metadata__license_teim"]).to eq ['http://example.org/blah']
    end
  end
  describe "delegation" do
    it "should retrieve values" do
      subject.descMetadata.title = "bla"
      expect(subject.title).to eq ["bla"]
    end
    it "should set values" do
      subject.title = "blah"
      expect(subject.descMetadata.title).to eq ["blah"]
    end
  end
  describe "attribute setting" do
    before(:each) do
      subject.descMetadata.title = "bla"
      dummy = DummySubnode.new
      dummy.title = 'subbla'
      subject.descMetadata.license = dummy
    end
    it "should let you access text attributes" do
      expect(subject.descMetadata.title).to eq ["bla"]
    end
    it "should let you access resource attributes" do
      expect(subject.descMetadata.license.first.title).to eq ['subbla']
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
