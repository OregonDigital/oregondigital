require 'spec_helper'

describe "catalog/_admin_show_tools.html.erb" do
  let(:asset) { FactoryGirl.build(:generic_asset) }
  let(:decorated_object) { asset.decorate }
  let(:stub_permissions) {}
  before do
    stub_permissions
    asset.stub(:pid).and_return("oregondigital:bla")
    asset.stub(:persisted?).and_return(true)
  end
  context "when the user is an admin" do
    let(:stub_permissions) { controller.stub(:can?).and_return(true) }
    context "when the object is not soft deleted" do
      it "should have a soft destroy link" do
        render "catalog/admin_show_tools.html.erb", :decorated_object => decorated_object, :id => "bla"
        expect(rendered).to have_css "a[data-method='delete'][href='#{generic_asset_path(:id => asset.pid)}']", :text => "Delete"
      end
    end
    context "and the object is soft deleted" do
      before do
        asset.stub(:soft_destroyed?).and_return(true)
      end
      it "should have an undelete link" do
        render "catalog/admin_show_tools.html.erb", :decorated_object => decorated_object, :id => "bla"
        expect(rendered).to have_link "Undelete", :href => undelete_destroyed_path(asset.pid)
      end
    end
  end
end
