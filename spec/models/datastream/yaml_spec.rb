require 'spec_helper'

describe Datastream::Yaml do
  subject(:datastream) {Datastream::Yaml.new}
  let(:asset) {DummyAsset.new}
  before(:all) do
    @content = File.read(File.join(fixture_path, "fixture_yml.yml"))
  end
  before(:each) do
    class DummyAsset < ActiveFedora::Base
      has_metadata 'descMetadata', :type => Datastream::Yaml
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyAsset") if Object
  end
  describe ".to_solr" do
    context "when there is no content" do
      it "should return an empty hash" do
        expect(subject.to_solr).to eq({})
      end
    end
    context "when there is content" do
      subject {asset.descMetadata}
      before(:each) do
        asset.descMetadata.content = @content
      end
      it "should return all the root keys that have content" do
        keys = subject.to_solr.keys
        expect(subject.to_solr.keys).to include("desc_metadata__third_root_teim")
      end
      it "should index child keys" do
        keys = subject.to_solr.keys
        expect(subject.to_solr.keys).to include("desc_metadata__oregondigital__test_key_teim")
      end
      it "should index arrays" do
        expect(subject.to_solr["desc_metadata__oregondigital__test_key_teim"]).to eq ["5","6","7"]
      end
      it "should be included in the asset's solr information" do
        expect(asset.to_solr).to include("desc_metadata__oregondigital__test_key_teim")
      end
    end
  end

  describe "content=" do
    before(:each) do
     subject.content = @content
    end
    it "should allow access to root elements" do
      expect(subject.third_root).to eq "Huskies"
    end
    it "should recursively openstruct-ify nested hashes" do
      expect(subject.second_root.element).to eq "Ducks"
    end
    it "should parse arrays" do
      expect(subject.oregondigital.test_key).to eq [5,6,7]
    end
  end
  describe ".content" do
    context "before content is set" do
      it "should be blank" do
        expect(subject.content).to be_blank
      end
    end
    context "when a setter was used to add content" do
      before(:each) do
        subject.oregondigital = "test"
      end
      it "should be able to get that attribute back" do
        expect(subject.oregondigital).to eq "test"
      end
      it "should persist that to content" do
        expect(subject.content).to include("test")
      end
    end
    context "when content is set" do
      before(:each) do
        subject.content = @content
      end
      it "should be the YML of the set content" do
        hash = YAML.load(subject.content)
        other_hash = YAML.load(@content)
        expect(hash.to_s).to eq other_hash.to_s
      end
      context "when a value is transformed" do
        before(:each) do
          subject.oregondigital = "blablabla"
        end
        it "should transform the serialized YML" do
          expect(subject.content).to include("blablabla")
        end
      end
    end
  end
  describe "asset.save" do
    context "when it has content" do
      before(:each) do
        asset.descMetadata.content = @content
        asset.save
      end
      it "should store the data in Fedora" do
        reloaded_asset = DummyAsset.find(asset.pid)
        expect(reloaded_asset.descMetadata.content.to_s).to eq asset.descMetadata.content.to_s
      end
    end
  end
end
