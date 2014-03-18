
shared_examples 'a collection' do
  before(:each) do
    class TestItem < GenericAsset
    end
  end
  subject(:generic_collection) { described_class.new }
  subject(:item) { TestItem.new }
  subject(:other_item) { TestItem.new }

  before(:each) do
    generic_collection.save!
    item.save!
    other_item.save!
  end
  after(:each) do
    Object.send(:remove_const, :TestItem) if Object.const_defined?(:TestItem)
  end

  describe '.members' do
    it 'should be empty when no items belong' do
      expect(generic_collection.members).to eq []
    end
    it 'should return collected items' do
      item.set = generic_collection
      item.save
      generic_collection.reload
      expect(generic_collection.members).to eq [item]
      other_item.set = generic_collection
      other_item.save
      generic_collection.reload
      expect(generic_collection.members).to include(item)
      expect(generic_collection.members).to include(other_item)
    end
  end
end
