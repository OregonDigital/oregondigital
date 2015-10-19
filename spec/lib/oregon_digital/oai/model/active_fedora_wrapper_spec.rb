require 'spec_helper'

describe OregonDigital::OAI::Model::ActiveFedoraWrapper do
  context "when initiated with a generic asset" do
    subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset)}
    let(:collection_1) do
      f = FactoryGirl.build(:generic_collection)
      f.save
      f
    end
    let(:generic_asset_1) do
      f = FactoryGirl.build(:generic_asset)
      f.save
      f
    end
    let(:generic_asset_2) do
      f = FactoryGirl.build(:generic_asset)
      f.save
      f
    end
    let(:generic_asset_3) {FactoryGirl.create(:generic_asset)}
    before(:each) do
      generic_asset_1
      sleep(1)
      generic_asset_2
      generic_asset_1.reload
      generic_asset_2.reload
      expect(generic_asset_1.modified_date).not_to eq generic_asset_2.modified_date
    end
    describe "#find" do
      context "when given :all" do
        it "should return all records" do
          expect(subject.find(:all).length).to eq 2
        end
      end
      context "when given a limit" do
        before do
          sleep(1)
          generic_asset_3
        end
        subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset, :limit => 1)}
        it "should return only that many" do
          expect(subject.find(:all).records.length).to eq 1
        end
        it "should provide a token" do
          expect(subject.find(:all).token.last).to eq 1
        end
        it "should provide a usable token" do
          token = subject.find(:all, :metadata_prefix => 'oai_dc').token.send(:encode_conditions)
          middle_result = subject.find(:all, :resumption_token => token)
          expect(middle_result.records).to eq [generic_asset_2]
          expect(subject.find(:all, :resumption_token => middle_result.token.send(:encode_conditions))).to eq [generic_asset_1]
        end
      end
      context "when given an id" do
        it "should return that record" do
          expect(subject.find(generic_asset_1.pid).first).to eq generic_asset_1
        end
      end
      context "when given a set" do
        before do
          generic_asset_1.set = collection_1
          generic_asset_1.save
        end
        it "should return records belonging to set " do
          expect(subject.find('', :set => collection_1.pid).first).to eq generic_asset_1
        end
      end
    end
    describe "#earliest" do
      it "should return the earliest modified_date timestamp" do
        ga_time = generic_asset_1.modified_date.to_time(:utc)
        expect(subject.earliest).to eq ga_time.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
    end
    describe "#latest" do
      it "should return the latest modified_date timestamp" do
        ga_time = generic_asset_2.modified_date.to_time(:utc)
        expect(subject.latest).to eq ga_time.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
    end
    describe "#sets" do
      before do
        collection_1
      end
      it "should return an array with the coll" do
        expect(subject.sets.first.name).to eq collection_1.title
      end
    end
  end
end
