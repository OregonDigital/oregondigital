require 'spec_helper'

describe GenericAsset do
  subject(:generic_asset) {GenericAsset.new}
  it "should initialize" do
    expect{generic_asset}.not_to raise_error
  end
  describe "pid assignment" do
    context "before the object is saved" do
      it "should be a filler PID" do
        expect(generic_asset.pid).to eq "__DO_NOT_USE__"
      end
    end
    context "when a new object is saved" do
      context "when it doesn't have a pid" do
        before(:each) do
          OregonDigital::IdService.should_receive(:mint).and_call_original
          generic_asset.save
        end
        it "should no longer be a filler PID" do
          expect(generic_asset.pid).not_to eq "__DO_NOT_USE__"
        end
        it "should be a valid NOID" do
          expect(OregonDigital::IdService.valid?(generic_asset.pid)).to eq true
        end
      end
      context "but it already has a pid" do
        subject(:generic_asset) {GenericAsset.new(:pid => "changeme:monkeys")}
        before(:each) do
          generic_asset.save
        end
        it "should not override the pid" do
          expect(generic_asset.pid).to eq "changeme:monkeys"
          expect(generic_asset).to be_persisted
        end
      end
    end
  end
end