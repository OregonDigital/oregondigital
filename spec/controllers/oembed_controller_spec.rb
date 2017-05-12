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
      it 'should return a 501' do
        expect(page.status_code).to eq(501)
      end
    end
    context 'if asset is not supported type' do
      it 'should return a 401' do
        expect(page.status_code).to eq(401)
      end
    end
    context 'if asset is an image' do
      it 'should call image_responder' do
        expect(image_responder).to receive(pid)
      end
    end
    context 'if asset is a video' do
      it 'should call video_responder' do
      end
    end
  end
  describe '#image_responder' do
    context 'when given an asset' do
      context 'if the asset has no location' do
        it 'should return a 401' do
          expect(page.status_code).to eq(401)
        end
      end
      context 'if the requested format is json' do
        it 'should call json_response' do
          expect(json_response).to receive()
        end
      end
    end
  end
  describe '#video_responder' do
    context 'when given an asset' do
      context 'if the asset has no location' do
        it 'should return a 401' do
          expect(page.status_code).to eq(401)
        end
      end
      context 'if the requested format is json' do
        it 'should call json_response' do
        end
      end
    end
  end
  describe '#json_response' do
    context 'when given data' do
      it 'should render a page' do
      end
    end
  end
end
