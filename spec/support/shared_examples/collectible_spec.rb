
shared_examples 'a collectible item' do
  class TestDatastream < ActiveFedora::NtriplesRDFDatastream
    map_predicates do |map|
      map.title(:in => RDF::DC)
    end
  end
  class TestCollection < ActiveFedora::Base
    include OregonDigital::Collection
    has_metadata 'descMetadata', type: TestDatastream
    delegate_to :descMetadata, [:title]
  end
  subject(:item) { described_class.new }
  subject(:collection) { TestCollection.new }
  subject(:other_collection) { TestCollection.new }

  before(:each) do
    item.save
    collection.save
  end
  describe '.collection' do
    it 'should be empty when there are no collections' do
      expect(item.collections).to eq []
    end
    it 'should return multiple collections' do
      item.collections << collection
      item.collections << other_collection
      item.save
      expect(item.collections).to include collection
      expect(item.collections).to include other_collection
      expect(collection.reload.members).to include item
    end
    it 'should write collections to metadata'
    it 'should not save collection' do
      collection.title = 'blah'
      item.collections << collection
      expect(TestCollection.find(collection.pid).title).not_to eq 'blah'
      collection.save
      expect(TestCollection.find(collection.pid).title).to eq ['blah']
    end
  end
end
