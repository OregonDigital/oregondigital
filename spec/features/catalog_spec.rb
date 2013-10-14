require 'spec_helper'

describe 'catalog' do
  describe 'search results' do
    context "when there is a collection" do
      before(:each) do
        FactoryGirl.create(:generic_collection)
      end
      it "should not show up in search results" do
        visit root_path(:search_field => "all_field")
        expect(page).not_to have_selector('.document')
      end
    end
  end
end
