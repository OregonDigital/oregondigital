require 'spec_helper'

describe "IP Roles" do
  context "when an item is restricted to an IP" do
    let(:role) {Role.new(:name=>"University-of-Oregon")}
    let(:ip_range) {IpRange.create(:role => role, :ip_start => ip, :ip_end => ip)}
    let(:ip) {"128.0.0.0"}
    let(:asset) do
      a = FactoryGirl.create(:generic_asset)
      a.read_groups = [role.name]
      a.save
      a
    end
    before do
      ip_range
      asset
    end
    context "as a guest user" do
      context "who has the right IP" do
        before do
          ActionDispatch::Request.any_instance.stub(:remote_ip).and_return(ip)
          visit catalog_path(asset.pid)
        end
        it "should be viewable" do
          expect(page).to have_content asset.title
        end
      end
      context "who has the wrong IP" do
        before do
          visit catalog_path(asset.pid)
        end
        it "should not be viewable" do
          expect(page).not_to have_content(asset.title)
          expect(page).to have_content("VPN")
        end
      end
    end
  end
end
