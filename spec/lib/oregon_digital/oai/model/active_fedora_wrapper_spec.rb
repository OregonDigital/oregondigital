require 'spec_helper'

describe OregonDigital::OAI::Model::ActiveFedoraWrapper do
  context "when initiated with a generic asset" do
    subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset)}
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
      context "when given an id" do
        it "should return that record" do
          expect(subject.find(generic_asset_1.pid).first).to eq generic_asset_1
        end
      end
    end
    describe "#earliest" do
      it "should return the earliest modified_date timestamp" do
        expect(subject.earliest).to eq generic_asset_1.modified_date
      end
    end
    describe "#latest" do
      it "should return the latest modified_date timestamp" do
        expect(subject.latest).to eq generic_asset_2.modified_date
      end
    end
  end
end
