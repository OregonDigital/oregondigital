require 'spec_helper'

describe OembedController, :resque => true do

  describe '#traffic_control' do
    context 'when given a request' do
      context 'if asset is nil' do
        before do
          visit("http://#{APP_CONFIG['default_host']}/oembed/?format=json&url=http://#{APP_CONFIG['default_host']}/resource/oregondigital:abc123456")
        end
        it 'should return a 404' do
          expect(page.status_code).to eq(404)
        end
      end
    end
    context 'if asset is not public' do
      let(:generic_asset) { FactoryGirl.build(:generic_asset) }
      before do
        generic_asset.read_groups = ["admin"]
        generic_asset.save
        visit("http://#{APP_CONFIG['default_host']}/oembed/?format=json&url=http://#{APP_CONFIG['default_host']}/resource/#{generic_asset.pid}")
      end
      it 'should return a 401' do
        expect(page.status_code).to eq(401)
      end
    end
    context 'if asset is not supported type' do
      let(:document) { Document.new }
      before do
        document.title = "my doc"
        document.review
        document.save
        visit("http://#{APP_CONFIG['default_host']}/oembed/?format=json&url=http://#{APP_CONFIG['default_host']}/resource/#{document.pid}")
      end
      it 'should return a 501' do
        expect(page.status_code).to eq(501)
      end
    end
    context 'if asset is an image' do
      context 'if asset has no location' do
        let(:image) { Image.new }
        before do
          image.title = "my image"
          image.review
          image.save
          visit("http://#{APP_CONFIG['default_host']}/oembed/?format=json&url=http://#{APP_CONFIG['default_host']}/resource/#{image.pid}")
        end
        it 'should return a 404' do
          expect(page.status_code).to eq(404)
        end
      end
      context 'if asset has an image file' do
        let(:image) { Image.new }
        let(:img) {{'width'=> 550, 'height'=>550}}
        before do
          image.title = "my image"
          image.review
          image.save
          allow(File).to receive(:exist?).and_return(true)
          allow(MiniMagick::Image).to receive(:open).and_return(img)
          visit("http://#{APP_CONFIG['default_host']}/oembed/?format=json&url=http://#{APP_CONFIG['default_host']}/resource/#{image.pid}")
        end
        it 'should have content' do
          expect(page.body).to include("photo")
        end
      end
    end
  end
end
