require "spec_helper"
describe OregonDigital::Workflow do
  class WorkflowAsset < ActiveFedora::Base
    include OregonDigital::Workflow
  end

  subject(:asset) { WorkflowAsset.new }
  after(:each) do
    subject.delete if subject.persisted?
  end
  it "should initialize items with unreviewed workflow metadata" do
    asset.save
    expect(asset.workflowMetadata.reviewed).to eq false
  end
  it "should set the solr representation to have reviewed information" do
    expect(asset.to_solr.keys).to include("reviewed_ssim")
  end

  describe 'review' do
    subject(:asset) { WorkflowAsset.new }
    it "should mark the item as reviewed" do
      asset.review
      expect(asset.workflowMetadata.reviewed).to eq true
    end
    it "should not save the item" do
      asset.review
      expect(asset.persisted?).to eq false
    end
  end
  describe 'review!' do
    subject(:asset) { WorkflowAsset.new }
    it "should mark the item as reviewed" do
      asset.review!
      expect(asset.workflowMetadata.reviewed).to eq true
    end
    it "should save the item" do
      asset.review!
      expect(asset.persisted?).to eq true
    end
  end
  describe 'reviewed?' do
    it "should return workflow review status" do
      asset.workflowMetadata.reviewed = false
      expect(asset.reviewed?).to eq false
      asset.workflowMetadata.reviewed = true
      expect(asset.reviewed?).to eq true
    end
  end
  describe 'reset_workflow' do
    it "should reset review status to false" do
      asset.workflowMetadata.reviewed = true
      asset.reset_workflow!
      expect(asset.reviewed?).to eq false
    end
    it "should not save the item" do
      asset.reset_workflow
      expect(asset.persisted?).to eq false
    end
  end
  describe 'reset_workflow!' do
    it "should reset review status to false" do
      asset.workflowMetadata.reviewed = true
      asset.reset_workflow!
      expect(asset.reviewed?).to eq false
    end
    it "should save the item" do
      asset.reset_workflow!
      expect(asset.persisted?).to eq true
    end
  end
end
