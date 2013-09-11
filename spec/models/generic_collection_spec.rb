require 'spec_helper'

describe GenericCollection do
  subject(:generic_collection) { GenericCollection.new }

  it 'should initialize' do
    expect { generic_collection }.not_to raise_error
  end

  context 'with objects' do
    before do
      generic_collection.save
      @item = GenericAsset.new
      @item.save
      @item.descMetadata.set = [generic_collection.pid]
      @item.save
    end
    it 'should return  all objects it collects' do
      expect(generic_collection.objects).to eq [@item]
    end
    it 'should return pids for all objects it collects' do
      expect(generic_collection.object_ids).to eq [@item.pid]
    end
  end
end
