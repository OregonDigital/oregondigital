require 'spec_helper'

describe GenericCollection do
  subject(:generic_collection) { GenericCollection.new }
  subject(:item) { GenericAsset.new }
  subject(:other_item) { GenericAsset.new }

  before(:each) do
    generic_collection.save
    item.save
    other_item.save
  end

  describe 'RELS metadata' do
    context 'empty set' do
      it 'should be empty when no items belong' do
        expect(generic_collection.relationships(:has_member)).to eq []
      end
    end
    context 'with items' do
      before(:each) do
        item.collections << generic_collection
      end
      it 'should store relationships to current objects' do
        expect(generic_collection.relationships(:has_member)).to eq item
        other_item.collections << generic_collection
        expect(generic_collection.relationships(:has_member)).to include item
        expect(generic_collection.relationships(:has_member)).to include other_item
      end
      it 'should remove relationships when items are removed' do
        expect(generic_collection.relationships(:has_member)).to include item
        item.collections << []
        expect(generic_collection.relationships(:has_member)).not_to include item
      end
    end
  end

  describe '.objects' do
    it 'should be empty when no items belong' do
      expect(generic_collection.objects).to eq []
    end
    context 'with items' do
      before(:each) do
        item.collections << generic_collection
      end
      it 'should return collected items' do
        expect(generic_collection.objects).to eq item
        other_item.collections << generic_collection
        expect(generic_collection.objects).to include item
        expect(generic_collection.objects).to include other_item
      end
      it 'should remove items' do
        expect(generic_collection.objects).to include item
        item.collections << []
        expect(generic_collection.objects).not_to include item
      end
    end
  end
end
