require 'spec_helper'

describe RolesIpRangesController do
  let(:user) {}
  let(:role) {instance_double("Role")}
  let(:ip_range) {instance_double("IpRange")}
  let(:create_parameters) { { :role_id => role.id, :ip_range_start => "1.1.1.1", :ip_range_end => "1.1.1.2" } }
  let(:delete_parameters) { { :role_id => role.id, :id => ip_range.id } }
  before do
    sign_in(user) if user
    setup_interface
  end

  def setup_interface
    # Role Interface
    allow(role).to receive(:id).and_return(1)
    allow(Role).to receive(:find).with(role.id.to_s).and_return(role)
    # IP Interface
    allow(ip_range).to receive(:id).and_return(1)
    allow(ip_range).to receive(:save).and_return(true)
  end

  def run_create
    post :create, create_parameters
  end

  context "when a user" do
    describe "POST create" do
      it "should be unauthorized" do
        expect{run_create}.to raise_error(CanCan::AccessDenied)
      end
    end
    describe "DELETE destroy" do
      it "should be unauthorized" do
        expect{delete :destroy, delete_parameters}.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  context "when an admin" do
    # Better way to do this?
    before do
      controller.stub(:authorize!)
      IpRange.stub(:new).and_return(ip_range)
    end
    describe "POST create" do
      it "should create an IP range" do
        IpRangeCreator.stub(:call) do
          controller.create_success(ip_range, role)
        end
        run_create
        expect(IpRangeCreator).to have_received(:call).with(role, controller.params, controller)
      end
    end
    describe "create_success" do
      before do
        IpRangeCreator.stub(:call) do
          controller.create_success(ip_range, role)
        end
        run_create
      end
      it "should redirect" do
        expect(response).to be_redirect
      end
    end
    describe "create_failure" do
      before do
        IpRangeCreator.stub(:call) do
          controller.create_failure(ip_range, role)
        end
        run_create
      end
      context "when it fails" do
        it "should redirect" do
          expect(response).to be_redirect
        end
        it "should set an error" do
          expect(flash[:error]).to eq "Invalid data given for IP Range"
        end
      end
    end
  end
end
