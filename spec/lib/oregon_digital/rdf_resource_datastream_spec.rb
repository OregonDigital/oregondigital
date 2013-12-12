require 'spec_helper'

describe OregonDigital::RdfResourceDatastream do
  before(:each) do
    class DummySubnode < OregonDigital::RDF::RdfResource
      property :title, :predicate => RDF::DC[:title], :class_name => RDF::Literal
      property :relation, :predicate => RDF::DC[:relation]
    end
    class DummyAsset < ActiveFedora::Base; end;
    class DummyResource < OregonDigital::RdfResourceDatastream
      property :title, :predicate => RDF::DC[:title], :class_name => RDF::Literal do |index|
        index.as :searchable, :displayable
      end
      property :license, :predicate => RDF::DC[:license], :class_name => DummySubnode do |index|
        index.as :searchable, :displayable
      end
      property :creator, :predicate => RDF::DC[:creator], :class_name => DummyAsset do |index|
        index.as :searchable
      end
      def serialization_format
        :ntriples
      end
    end
    class DummyAsset < ActiveFedora::Base
      include OregonDigital::RDF::RdfIdentifiable
      has_metadata :name => 'descMetadata', :type => DummyResource
      delegate :title, :to => :descMetadata, :multiple => true
      delegate :license, :to => :descMetadata, :multiple => true
      delegate :relation, :to => 'descMetadata', :at => [:license, :relation], :multiple => false
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyAsset") if Object
    Object.send(:remove_const, "DummyResource") if Object
    Object.send(:remove_const, "DummySubnode") if Object
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
    context "when the delegation is deep" do
      before(:each) do
        dummy = DummySubnode.new
        dummy.relation = 'subbla'
        subject.descMetadata.license = dummy
      end
      # This test is pending. For now we have no use case for deep delegation into an RDF graph.
      xit "should retrieve values" do
        expect(subject.relation).to eq ["subbla"]
      end
    end
  end
  describe "attribute setting" do
    context "on text attributes" do
      before(:each) do
        subject.descMetadata.title = "bla"
      end
      it "should let you access" do
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
    context "on rdf resource attributes" do
      context "persisted to parent" do
        before(:each) do
          dummy = DummySubnode.new
          dummy.title = 'subbla'
          subject.descMetadata.license = dummy
        end
        it "should let you access" do
          expect(subject.descMetadata.license.first.title).to eq ['subbla']
        end
        it "should mark it as changed" do
          expect(subject.descMetadata).to be_changed
        end
      end
      context "persisted to repository" do
        before(:each) do
          OregonDigital::RDF::RdfRepositories.add_repository :default, RDF::Repository.new
          DummySubnode.configure :repository => :default
          dummy = DummySubnode.new(RDF::URI('http://example.org/dummy/blah'))
          dummy.title = 'subbla'
          # We want to have to manually persist to the repository.
          # Parent objects shouldn't be persisting children they share with other parents
          dummy.persist!
          subject.descMetadata.license = dummy
        end
        it "should let you access" do
          expect(subject.descMetadata.license.first.title).to eq ['subbla']
        end
        it "should mark it as changed" do
          expect(subject.descMetadata).to be_changed
        end
      end
    end
  end
  describe "asset.load_instance_from_solr" do
    before(:each) do
      subject.descMetadata.title = "Monkeys"
      subject.save
      @loaded_object = DummyAsset.load_instance_from_solr(subject.pid)
    end
    it "should load the datastream" do
      expect(@loaded_object.title).to eq ["Monkeys"]
    end
  end
  describe "relationships" do
    before(:each) do
      @new_object = DummyAsset.new
      @new_object.title = "subbla"
      @new_object.save
      subject.title = "bla"
      subject.descMetadata.creator = @new_object
    end
    it "should have accessible relationship attributes" do
      expect(subject.descMetadata.creator.first.title).to eq ["subbla"]
    end
    it "should let me get to an AF:Base object" do
      subject.save
      subject.reload
      expect(subject.descMetadata.creator.first).to be_kind_of(ActiveFedora::Base)
    end
    it "should allow for deep attributes to be set directly" do
      subject.descMetadata.creator.first.title = "Bla"
      expect(subject.descMetadata.creator.first.title).to eq ["Bla"]
    end
    context "when the object with a relationship is saved" do
      before(:each) do
        subject.save
        @object = subject.class.find(subject.pid)
      end
      it "should be retrievable" do
        expect(subject.descMetadata.creator.first.title).to eq ["subbla"]
      end
    end
  end
end
