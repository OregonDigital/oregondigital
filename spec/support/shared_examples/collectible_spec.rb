
shared_examples 'a collectible item' do
  class TestCollection < ActiveFedora::Base
    include OregonDigital::Collection
  end
  subject(:item) { described_class.new }
  subject(:collection) { TestCollection.new }
  subject(:other_collection) { TestCollection.new }

  before(:each) do
    item.save
    collection.save
  end
  describe '.collections' do
    it 'should be empty when there are no collections' do
      expect(item.collections).to eq []
    end
    it 'should return multiple collections' do
      item.collections << collection
      item.collections << other_collection
      expect(item.collections).to include collection
      expect(item.collections).to include other_collection
    end
    it 'should write collections to metadata' do
      item.collections << collection
      item.collections << other_collection
    end
    it 'should not save collection' do
      collection.title = 'blah'
      item.collecitons << collection
      item.save
      expect(TestCollection.find(g.pid).title).not_to == 'blah'
      collection.save
      expect(TestCollection.find(g.pid).title).to == 'blah'
    end
  end
end
