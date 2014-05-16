require 'spec_helper'

describe DocumentController do
  context "when there is a document" do
    context "with a pdf datastream" do
      let(:document) do
        d = FactoryGirl.create(:document, :with_pdf_datastream)  
        d.create_derivatives
        d
      end
      describe '.show' do
        let(:json) {JSON.parse(response.body)}
        before do
          get :show, :id => document.pid, :format => :json
        end
        it "should not load up the image" do
          expect(MiniMagick::Image).not_to receive(:open)
          get :show, :id => document.pid, :format => :json
        end
        it "should have pages" do
          expect(json['pages'].length).to eq 2
        end
        it "should have size data" do
          expect(json['pages']).to eq [{"size" => {"width" => 1000, "height" => 1254}}, {"size" => {"width" => 1000, "height" => 1254}}]
        end
      end
    end
  end
end
