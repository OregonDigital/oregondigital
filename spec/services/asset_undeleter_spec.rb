require 'spec_helper'

describe AssetUndeleter do
  let(:asset) { instance_double("GenericAsset").as_null_object }
  let(:callback) { double("callback").as_null_object }
  describe ".call" do
    let(:result) { AssetUndeleter.call(asset, callback) }
    context "when given an asset" do
      it "should call undelete! on it" do
        expect(asset).to receive(:undelete!)
        result
      end
      it "should call #success on the callback" do
        expect(callback).to receive(:success).with(asset)
        result
      end
    end
  end
end
