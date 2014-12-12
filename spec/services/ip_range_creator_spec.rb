require 'spec_helper'

describe IpRangeCreator do
  let(:ip_range) { instance_double("IpRange") }
  let(:role) { instance_double("Role") }
  let(:callback) { double("callback") }
  let(:create_parameters) { { :ip_range_start => "1.1.1.1", :ip_range_end => "1.1.1.2" } }
  before do
    IpRange.stub(:new).and_return(ip_range)
    stub_callback_interface
    stub_ip_range_interface
  end

  def stub_callback_interface
    callback.stub(:create_success)
    callback.stub(:create_failure)
  end

  def stub_ip_range_interface
    ip_range.stub(:ip_start=)
    ip_range.stub(:ip_end=)
    ip_range.stub(:role=)
    ip_range.stub(:save).and_return(true)
  end
  

  describe ".call" do
    subject { IpRangeCreator.call(role, create_parameters, callback) }
    it "should set parameters" do
      expect(ip_range).to receive(:ip_start=).with("1.1.1.1")
      expect(ip_range).to receive(:ip_end=).with("1.1.1.2")
      expect(ip_range).to receive(:role=).with(role)
      subject
    end
    context "and save succeeds" do
      it "should call create_success on the callback" do
        expect(callback).to receive(:create_success)
        subject
      end
    end
    context "and save fails" do
      before do
        ip_range.stub(:save).and_return(false)
      end
      it "should call create_failure on the callback" do
        expect(callback).to receive(:create_failure)
        subject
      end
    end
  end
end
