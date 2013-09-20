require 'spec_helper'

class DummyAsset < ActiveFedora::Base
  has_metadata 'descMetadata', :type => YamlDatastream
end

describe YamlDatastream do
  subject(:datastream) {YamlDatastream.new}
  let(:asset) {DummyAsset.new}
  before(:all) do
    @content = File.read(File.join(fixture_path, "fixture_yml.yml"))
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
      after(:each) do
        asset.destroy
      end
      it "should store the data in Fedora" do
        reloaded_asset = DummyAsset.find(asset.pid)
        expect(reloaded_asset.descMetadata.content.to_s).to eq asset.descMetadata.content.to_s
      end
    end
  end
end