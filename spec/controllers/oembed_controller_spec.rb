require 'spec_helper'

describe OembedController, :resque => true do
  let(:subject) { described_class.new }
  describe '#traffic_control' do
    context 'when given a request' do
      context 'but pid is not valid' do
        before do
          visit("#{APP_CONFIG['default_url_host']}/oembed/?format=json&url=#{APP_CONFIG['default_url_host']}/resource/blah")
        end
        it 'should return a 400' do
          expect(page.status_code).to eq(400)
        end
      end
      context 'if there is no solr doc' do
        before do
          visit("#{APP_CONFIG['default_url_host']}/oembed/?format=json&url=#{APP_CONFIG['default_url_host']}/resource/oregondigital:abc123456")
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
        generic_asset.save!
        visit("#{APP_CONFIG['default_url_host']}/oembed/?format=json&url=#{APP_CONFIG['default_url_host']}/resource/#{generic_asset.pid}")
      end
      it 'should return a 401' do
        expect(page.status_code).to eq(401)
      end
    end
    context 'if request does not specify format' do
      let(:generic_asset) { FactoryGirl.build(:generic_asset) }
      before do
        visit("#{APP_CONFIG['default_url_host']}/oembed/?url=#{APP_CONFIG['default_url_host']}/resource/#{generic_asset.pid}")
      end
      it 'should return a 400' do
        expect(page.status_code).to eq(400)
      end
    end
    context 'if asset is not supported type' do
      let(:audio) { Audio.new }
      before do
        audio.title = "my doc"
        audio.review
        audio.save
        visit("#{APP_CONFIG['default_url_host']}/oembed/?format=json&url=#{APP_CONFIG['default_url_host']}/resource/#{audio.pid}")
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
          visit("#{APP_CONFIG['default_url_host']}/oembed/?format=json&url=#{APP_CONFIG['default_url_host']}/resource/#{image.pid}")
        end
        it 'should return a 404' do
          expect(page.status_code).to eq(404)
        end
      end
      context 'if asset has an image file' do
        let(:image) { image = FactoryGirl.create(:image, :with_jpeg_datastream) }
        before do
          image.title = "my image"
          image.create_derivatives
          image.review
          image.save
          visit("#{APP_CONFIG['default_url_host']}/oembed/?format=json&url=#{APP_CONFIG['default_url_host']}/resource/#{image.pid}")
        end
        it 'should have content' do
          expect(page.body).to include("photo")
        end
      end
    end
    context 'if asset is a doc' do
      let(:document) do
        d = FactoryGirl.create(:document, :with_pdf_datastream)
        d.create_derivatives
        d
      end
      context 'and hitting the oembed provider' do
        before do
          visit("#{APP_CONFIG['default_url_host']}/oembed/?format=json&url=#{APP_CONFIG['default_url_host']}/resource/#{document.pid}")
        end
        it 'should have content' do
          expect(page.body).to include("embedded_reader")
        end
      end
      context 'and hitting the reader' do
        before do
          visit("#{APP_CONFIG['default_url_host']}/embedded_reader/#{document.pid}")
        end
        it 'should be a success' do
          expect(page.status_code).to eq(200)
        end
      end
    end
  end
  describe '#image' do
    context 'when there is an image request' do
      let(:data) do
        { "version" => "1.0",
          "type" => "photo",
          "width" => test_img["width"],
          "height" => test_img["height"],
          "url" => "http://localhost:3000/media/medium-images/a/1/oregondigital-abcde1234.jpg" }
      end
      let(:test_img) { MiniMagick::Image.open(Rails.root.join("spec/fixtures/fixture_image.tiff")) }
      before do
        allow(subject).to receive(:buckets).and_return("a/1")
        allow(subject).to receive(:modified_pid).and_return("oregondigital-abcde1234")
        allow(MiniMagick::Image).to receive(:open).and_return(test_img)
      end
      it 'assembles the data' do
        expect(subject.image).to eq(data)
      end
    end
  end
  describe '#document' do
    context 'when there is a document request' do
      let(:solr_doc) { { "leaf_metadata__pages__size__width_ssm" =>["400"], "leaf_metadata__pages__size__height_ssm" => ["700"] } }
      let(:data) do
        { "version" => "1.0",
          "type" => "rich",
          "html" => '<iframe src="http://localhost:3000/embedded_reader/oregondigital:abcde1234" width="870" height="600"></iframe>',
          "width" => "870",
          "height" => "600" }
      end
      before do
        allow(subject).to receive(:solr_doc).and_return(solr_doc)
        subject.instance_variable_set(:@pid, "oregondigital:abcde1234")
      end
      it 'assembles the data' do
        expect(subject.document).to eq(data)
      end
    end
  end
end
