require 'spec_helper'

describe GenericAsset do
  it_behaves_like 'a baggable item'
  it_behaves_like 'a collectible item'

  subject(:generic_asset) { GenericAsset.new }

  it 'should initialize' do
    expect { generic_asset }.not_to raise_error
  end

  describe 'collection metadata crosswalking' do
    context 'when the asset is a member of a collection' do
      let(:collection) {GenericCollection.create(:pid => "oregondigital:test")}
      before(:each) do
        subject.save
        subject.collections << collection
        subject.save
      end
      it "should remove info:fedora from od:set"
      it 'should populate od:set' do
        expect(subject.descMetadata.set).to eq ["info:fedora/oregondigital:test"]
      end
      it "should populate od:set after being reloaded" do
        item = GenericAsset.find(subject.pid)
        expect(item.descMetadata.set).to eq ["info:fedora/oregondigital:test"]
      end
      after(:each) do
        subject.destroy
        collection.destroy
      end
    end
  end

  describe 'pid assignment' do
    context 'before the object is saved' do
      it 'should be a filler PID' do
        expect(generic_asset.pid).to eq '__DO_NOT_USE__'
      end
    end
    context 'when a new object is saved' do
      context "when it doesn't have a pid" do
        before(:each) do
          OregonDigital::IdService.should_receive(:mint).and_call_original
          generic_asset.save
        end
        it 'should no longer be a filler PID' do
          expect(generic_asset.pid).not_to eq '__DO_NOT_USE__'
        end
        it 'should be a valid NOID' do
          expect(OregonDigital::IdService.valid?(generic_asset.pid)).to eq true
        end
      end
      context 'but it already has a pid' do
        subject(:generic_asset) { GenericAsset.new(:pid => 'changeme:monkeys') }
        before(:each) do
          generic_asset.save
        end
        it 'should not override the pid' do
          expect(generic_asset.pid).to eq 'changeme:monkeys'
          expect(generic_asset).to be_persisted
        end
      end
    end
  end
end
