require "spec_helper"
describe OregonDigital::Crosswalkable do
  before(:each) do
    class CrosswalkAsset < ActiveFedora::Base; end
  end

  context 'with RDFDatastreams' do
    context 'a simple crosswalk' do
      before(:each) do
        CrosswalkAsset.has_metadata :name => 'descMetadata', :type => OregonRDFDatastream
        CrosswalkAsset.has_metadata :name => 'xwalkMetadata', :type => OregonRDFDatastream do |ds|
          ds.crosswalk :field => :creator, :to => :creator, :in => :descMetadata
        end
        @i = CrosswalkAsset.new
      end
      it "should return the crosswalked field" do
        @i.descMetadata.creator = "John Berger"
        expect(@i.xwalkMetadata.creator).to eq @i.descMetadata.creator
        expect(@i.xwalkMetadata.creator).to eq ["John Berger"]
        @i.descMetadata.creator << "Susan Sontag"
        expect(@i.xwalkMetadata.creator).to eq ["John Berger", "Susan Sontag"]
      end
      it "should set the crosswalked field" do
        @i.xwalkMetadata.creator = "John Berger"
        expect(@i.descMetadata.creator).to eq ["John Berger"]
        @i.xwalkMetadata.creator << "Susan Sontag"
        expect(@i.descMetadata.creator).to eq ["John Berger", "Susan Sontag"]
        @i.xwalkMetadata.creator = []
        expect(@i.descMetadata.creator).to eq []
      end
      it "should serialize crosswalked data" do
        @i.descMetadata.creator = "John Berger"
        expect(@i.xwalkMetadata.content).to include "John Berger"
        @i.descMetadata.creator << "Susan Sontag"
        expect(@i.xwalkMetadata.content).to include "John Berger"
        expect(@i.xwalkMetadata.content).to include "Susan Sontag"
        @i.xwalkMetadata.creator = []
        expect(@i.xwalkMetadata.content).not_to include "John Berger"
      end
    end
    context "with bad crosswalk specs" do
      before(:each) do
        CrosswalkAsset.has_metadata :name => 'descMetadata', :type => OregonRDFDatastream
      end

      it "should throw an error when datastream doesn't exist" do
        CrosswalkAsset.has_metadata :name => 'xwalkMetadata', :type => OregonRDFDatastream do |ds|
          ds.crosswalk :field => :creator, :to => :creator, :in => :notRealMetadata
        end
        expect{ CrosswalkAsset.new }.to raise_error
      end
      it "should throw an error when target element doesn't exist" do
        CrosswalkAsset.has_metadata :name => 'xwalkMetadata', :type => OregonRDFDatastream do |ds|
          ds.crosswalk :field => :creator, :to => :notRealField, :in => :descMetadata
        end
        expect{ CrosswalkAsset.new }.to raise_error
      end
      it "should throw an error when field doesn't exist" do
        CrosswalkAsset.has_metadata :name => 'xwalkMetadata', :type => OregonRDFDatastream do |ds|
          ds.crosswalk :field => :notRealField, :to => :creator, :in => :descMetadata
        end
        expect{ CrosswalkAsset.new }.to raise_error
      end
    end
  end


  context 'with RDF and RELS-EXT Datastreams' do
    before(:each) do
      CrosswalkAsset.has_metadata :name => 'xwalkMetadata', :type => OregonRDFDatastream do |ds|
        ds.crosswalk :field => :set, :to => :is_member_of_collection, :in => "RELS-EXT"
      end
      @i = CrosswalkAsset.new
      @i.save
    end
    after(:each) do
      @i.destroy
    end

    it "should return the crosswalked field" do
      @i.add_relationship(:is_member_of_collection, "info:fedora/test:test")
      expect(@i.xwalkMetadata.set).to eq ["info:fedora/test:test"]
      @i.add_relationship(:is_member_of_collection, "info:fedora/test:newtest")
      expect(@i.xwalkMetadata.set).to eq ["info:fedora/test:test", "info:fedora/test:newtest"]
    end
    it "should not add duplicates" do
      @i.add_relationship(:is_member_of_collection, "info:fedora/test:test")
      @i.add_relationship(:is_member_of_collection, "info:fedora/test:test")
      expect(@i.xwalkMetadata.set).to eq ["info:fedora/test:test"]
    end
    it "should set the crosswalked field" do
      @i.xwalkMetadata.set = "info:fedora/test:testing"
      expect(@i.relationships(:is_member_of_collection)).to eq ["info:fedora/test:testing"]
      @i.xwalkMetadata.set << "info:fedora/test:testing2"
      expect(@i.relationships(:is_member_of_collection)).to eq ["info:fedora/test:testing","info:fedora/test:testing2"]
      @i.xwalkMetadata.set = []
      expect(@i.relationships(:is_member_of_collection)).to eq []
    end
    it "should serialize crosswalked data" do
      @i.add_relationship(:is_member_of_collection, "info:fedora/test:testing")
      expect(@i.xwalkMetadata.content).to include "info:fedora/test:testing"
      @i.add_relationship(:is_member_of_collection, "info:fedora/test:test2")
      expect(@i.xwalkMetadata.content).to include "info:fedora/test:testing"
      expect(@i.xwalkMetadata.content).to include "info:fedora/test:test2"
      @i.xwalkMetadata.set = []
      expect(@i.xwalkMetadata.content).not_to include "info:fedora/test:testing"
    end

    context "with bad crosswalk specs" do
    end
  end

  context 'with RDF and OmDatastreams' do
    context "with bad crosswalk specs" do
    end
  end

  context 'with OmDatastreams' do
    context "with bad crosswalk specs" do
    end
  end
end