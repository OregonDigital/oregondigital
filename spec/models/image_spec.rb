require 'spec_helper'

describe Image do
  subject(:image) {Image.new}
  describe 'datastreams' do
    it 'should have a content datastream' do
      expect(image.content).to be_kind_of(ActiveFedora::Datastream)
    end
    it 'should have a thumbnail datastream' do
      expect(image.thumbnail).to be_kind_of(ActiveFedora::Datastream)
    end
    it 'should have a pyramidal tiff datastream' do
      expect(image.pyramidal).to be_kind_of(ActiveFedora::Datastream)
    end
    it 'should have right data' do
      expect(image.rightsMetadata).to be_kind_of(Hydra::Datastream::RightsMetadata)
    end
  end

  describe '.create_derivatives' do
    after(:each) do
      image.destroy
    end
    context 'when the image has content' do
      before(:each) do
        file = File.open(File.join(fixture_path, 'hydra.png'))
        image.add_file_datastream(file, :dsid => 'content')
        expect(image.content).not_to be_blank
        image.save
        expect(image.thumbnail.content).to be_blank
        image.create_derivatives
      end
      it 'should populate the thumbnail datastream' do
        expect(image.thumbnail.content).not_to be_blank
      end
    end
  end
end