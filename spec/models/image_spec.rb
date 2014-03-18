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
      after(:each) do
        FileUtils.rm(image.pyramidal_tiff_location) if File.exists?(image.pyramidal_tiff_location)
        FileUtils.rm(image.thumbnail_location) if File.exists?(image.thumbnail_location)
      end
      it 'should populate the external thumbnail datastream' do
        expect(image.thumbnail.dsLocation).to eq("file://#{image.thumbnail_location}")
        expect(Image.find(image.pid).thumbnail.dsLocation).to eq("file://#{image.thumbnail_location}")
      end
      it "should save the external thumbnail" do
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(image.thumbnail_location).split(';')[0]
        expect(mime_type).to eq 'image/jpeg'
      end
      it "should resize the thumbnail" do
        f = MiniMagick::Image.open(image.thumbnail_location)
        expect(f['width']).to eq 120
        expect(f['height']).to eq 120
      end
      it 'should populate the external pyramidal datastream' do
        expect(image.pyramidal.dsLocation).to eq("file://" + image.pyramidal_tiff_location)
        expect(Image.find(image.pid).pyramidal.dsLocation).to eq("file://#{image.pyramidal_tiff_location}")
      end
      it 'should save the external pyramidal datastream' do
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(image.pyramidal_tiff_location).split(';')[0]
        expect(mime_type).to eq 'image/tiff'
      end
    end
  end

  describe "#pyramidal_tiff_location" do
    before(:each) do
      image.stub(:pid => "oregondigital:foobar")
    end
    it "should return a string containing the pid" do
      expect(image.pyramidal_tiff_location).to match(/#{image.pid.gsub(':', '-')}/)
    end

    it "should use APP_CONFIG for the base path" do
      APP_CONFIG.stub(:pyramidal_tiff_path => "/foo")
      expect(image.pyramidal_tiff_location).to match(%r|^/foo/|)
    end
  end
end
