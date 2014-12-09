require 'spec_helper'

describe "#soft_destroy" do
  let(:asset) { FactoryGirl.build(:generic_asset) }
  before do
    asset.stub(:save)
    asset.soft_destroy
  end
  it "should set #soft_destroyed?" do
    expect(asset).to be_soft_destroyed
  end
  it "should reset workflow" do
    expect(asset).to receive(:reset_workflow)
    asset.soft_destroy
  end

  describe "#undelete" do
    it "should not alter groups" do
      before_groups = asset.read_groups
      asset.undelete
      expect(asset.read_groups).to eq before_groups
    end
    it "should no longer be destroyed" do
      asset.undelete
      expect(asset).not_to be_soft_destroyed
    end
  end

  describe "#undelete!" do
    it "should call undelete" do
      expect(asset).to receive(:undelete)
      asset.undelete!
    end
    it "should call save" do
      expect(asset).to receive(:save)
      asset.undelete!
    end
  end
end
