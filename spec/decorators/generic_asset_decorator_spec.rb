require 'spec_helper'

describe GenericAssetDecorator do
  let(:subject) {GenericAssetDecorator.new(asset)}
  let(:asset) {FactoryGirl.build(:generic_asset)}
  let(:result) {subject.sorted_show_fields}
  describe "#sorted_show_fields" do
    before(:each) do
      I18n.stub(:t).and_call_original
    end

    context "when there is no configuration" do
      before(:each) do
        I18n.stub(:t).with("oregondigital.metadata").and_return({})
      end

      it "should return the keys with values" do
        expect(result).to eq ["title", "created"]
      end
      context "when a field has a value" do
        let(:asset) do
          g = FactoryGirl.build(:generic_asset)
          g.descMetadata.photographer = "Test Photographer"
          g
        end
        it "should return keys in the order they're defined in OregonRDF" do
          expect(result).to eq ["title", "photographer", "created"]
        end
      end
      context "when there is an I18n configuration for fields" do
        let(:asset) do
          g = FactoryGirl.build(:generic_asset)
          g.descMetadata.photographer = "Test Photographer"
          g
        end
        before(:each) do
          I18n.stub(:t).with("oregondigital.metadata").and_return({:photographer => "photographer", :created => "created"})
        end
        it "should organize those fields at the top in the given order" do
          expect(result).to eq ["photographer", "created", "title"]
        end
      end
    end
  end

end
