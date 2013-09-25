
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

  describe '.members' do
    it 'should be empty when no items belong' do
      expect(generic_collection.members).to eq []
    end
    it 'should return collected items' do
      generic_collection.members << item
      generic_collection.reload
      generic_collection.save
      expect(generic_collection.members).to eq [item]
      generic_collection.members << other_item
      expect(generic_collection.members).to include item
      expect(item.reload.collections).to include generic_collection
      expect(generic_collection.members).to include other_item
      expect(other_item.reload.collections).to include generic_collection
    end
  end
  describe '.delete' do
    it 'should remove relationships from items' do
      generic_collection.members << item
      generic_collection.save
      expect(item.reload.collections).to include generic_collection
      generic_collection.delete
      expect(item.reload.collections).to eq []
    end
  end
end
