
shared_examples 'a collection' do
  class TestItem < ActiveFedora::Base
    include OregonDigital::Collectible
  end
  subject(:generic_collection) { described_class.new }
  subject(:item) { TestItem.new }
  subject(:other_item) { TestItem.new }

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
        expect(generic_collection.relationships(:has_member)).to eq ["info/fedora/#{item.pid}"]
        other_item.collections << generic_collection
        expect(generic_collection.relationships(:has_member)).to include "info/fedora/#{item.pid}"
        expect(generic_collection.relationships(:has_member)).to include "info/fedora/#{other_item.pid}"
      end
      it 'should remove relationships when items are removed' do
        expect(generic_collection.relationships(:has_member)).to include "info/fedora/#{item.pid}"
        item.collections << []
        expect(generic_collection.relationships(:has_member)).not_to include "info/fedora/#{item.pid}"
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
    end
  end
  describe '.delete' do
    it 'should remove relationships from items' do
      item.collections << generic_collection
      generic_collection.delete
      expect(item.collections).not_to include collection
    end
  end
end
