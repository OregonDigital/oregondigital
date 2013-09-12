
shared_examples 'a collectible item' do
  subject(:item) { described_class.new }
  subject(:collection) { GenericCollection.new }
  subject(:other_collection) { GenericCollection.new }

  before(:each) do
    item.save
    collection.save
  end
  describe '.collections' do
    it 'should be empty when there are no collections' do
      expect(item.collections).to eq []
    end

    it 'should accept collections' do
      item.collections << collection
      expect(item.collections).to eq [collection]
    end

    it 'should accept multiple collections' do
      item.collections << collection
      item.collections << other_collection
      expect(item.collections).to include collection
      expect(item.collections).to include other_collection
    end
  end
end
