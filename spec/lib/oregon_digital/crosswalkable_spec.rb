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
        @i.descMetadata.creator << "Susan Sontag"
        expect(@i.xwalkMetadata.creator).to eq @i.descMetadata.creator

        expect(@i.xwalkMetadata.creator).to eq @i.descMetadata.creator
      end
      it "should set the crosswalked field" do
        @i.xwalkMetadata.creator = "John Berger"
        expect(@i.descMetadata.creator).to eq @i.xwalkMetadata.creator
        @i.xwalkMetadata.creator << "Susan Sontag"
        expect(@i.descMetadata.creator).to eq @i.xwalkMetadata.creator
        @i.xwalkMetadata.creator = []
        expect(@i.descMetadata.creator).to eq @i.xwalkMetadata.creator
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
        ds.crosswalk :field => :set, :to => :is_member_of_collection, :in => :rels_ext
      end
      @i = CrosswalkAsset.new
    end

    it "should return the crosswalked field"
    it "should set the crosswalked field"
    it "should serialize crosswalked data"

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
