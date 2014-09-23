require 'spec_helper'

describe BulkTaskChild do
  subject { FactoryGirl.build(:bulk_task_child, :ingested_pid => ingested_pid, :status => status) }
  let(:ingested_pid) {}
  let(:status) {"pending"}
  describe "validations" do
    it {should validate_presence_of(:target)}
    context "when the ingested_pid is set" do
      let(:ingested_pid) {"oregondigital:3000"}
      context "and the status is not ingested" do
        it "should be valid" do
          expect(subject).to be_valid
        end
      end
      context "and the status is ingested" do
        let(:status) {"ingested"}
        it "should be valid" do
          expect(subject).to be_valid
        end
      end
    end
    context "when the ingested pid is not set" do
      context "and the status is ingested" do
        let(:status) {"ingested"}
        it "should not be valid" do
          expect(subject).not_to be_valid
        end
      end
    end
  end
  
  describe "#asset" do
    context "when there is no ingested_pid" do
      it "should be nil" do
        expect(subject.asset).to be_nil
      end
    end
    context "when there is an ingested pid" do
      let(:ingested_pid) {asset.pid}
      let(:asset) {FactoryGirl.create(:generic_asset)}
      it "should be the asset" do
        expect(subject.asset).to eq asset
      end
    end
  end

  describe "ingest!" do
    context "when there's a HUGE error" do
      before do
        subject.stub(:bag_ingest!).and_raise("a"*200)
        subject.stub(:type).and_return(:bag)
        subject.ingest!
      end 
      it "should truncate the error" do
        expect(subject.result[:error][:message].length).to eq 150
      end
    end
  end

  describe "#status" do
    it "should be pending by default" do
      expect(subject.class.new).to be_pending
    end
  end
end
