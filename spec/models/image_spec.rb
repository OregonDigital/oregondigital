require 'spec_helper'
require 'filemagic'

describe Image do
  subject(:image) { Image.new }
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
    context 'when the image has content' do
      before(:each) do
        file = File.open(File.join(fixture_path, 'fixture_image.jpg'))
        image.add_file_datastream(file, :dsid => 'content')
        expect(image.content).not_to be_blank
        image.save
        image.create_derivatives
      end
      it 'should populate the thumbnail datastream' do
        expect(image.thumbnail.content).not_to be_nil
        expect(image.thumbnail.content).not_to eq ''
      end
      it 'should populate the pyramidal datastream' do
        expect(image.pyramidal.content).not_to be_nil
        expect(image.pyramidal.content).not_to eq ''
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).buffer(image.pyramidal.content).split(';')[0]
        expect(mime_type).to eq 'image/tiff'
      end
    end
  end
end
