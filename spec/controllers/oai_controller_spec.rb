require 'spec_helper'

describe OaiController do
  describe '#index' do
    before(:each) do
      get :index, :verb => "ListRecords", :metadataPrefix => "oai_dc"
    end
    it "should work" do
      expect(response).to be_success
    end
  end
end
