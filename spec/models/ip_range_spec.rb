require 'spec_helper'
require 'ipaddr'

describe IpRange do
  subject (:ip_range) {IpRange.new}
  describe ".ip_start=" do
    context "when given a valid IP" do
      before(:each) do
        subject.ip_start = "122.122.25.12"
      end
      it "should set ip_start_i" do
        expect(subject.ip_start_i).to eq IPAddr.new("122.122.25.12").to_i
      end
    end
    context "when given an invalid IP" do
      it "should not error" do
        expect{subject.ip_start = "bla"}.not_to raise_error
      end
    end
  end
  describe ".ip_end=" do
    context "when given a valid IP" do
      before(:each) do
        subject.ip_end = "122.122.25.12"
      end
      it "should set ip_start_i" do
        expect(subject.ip_end_i).to eq IPAddr.new("122.122.25.12").to_i
      end
    end
    context "when given an invalid IP" do
      it "should not error" do
        expect{subject.ip_end = "bla"}.not_to raise_error
      end
    end
  end
  describe ".ip_start_i=" do
    it "should raise an error" do
      expect{subject.ip_start_i = 122}.to raise_error
    end
  end
  describe ".ip_end_i=" do
    it "should raise an error" do
      expect{subject.ip_end_i = 122}.to raise_error
    end
  end
  describe "validations" do
    subject(:ip_range) do
      i = IpRange.new
      i.ip_start = ip_start
      i.ip_end = ip_end
      r = Role.new
      r.name = "Admin"
      i.role = r
      i
    end
    let(:ip_start) {"122.122.25.12"}
    let(:ip_end) {"122.122.25.12"}
    it "should be valid with the builder" do
      expect(subject).to be_valid
    end
    context "when ip_start is blank" do
      let(:ip_start) {nil}
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when ip_end is blank" do
      let(:ip_end) {nil}
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when role is blank" do
      before(:each) do
        subject.stub(:role).and_return(nil)
      end
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when ip_start_i is blank" do
      before(:each) do
        subject.stub(:ip_start_i).and_return(nil)
      end
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when ip_end_i is blank" do
      before(:each) do
        subject.stub(:ip_end_i).and_return(nil)
      end
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when ip_start is not an IP" do
      before(:each) do
        subject.stub(:ip_start).and_return("bla")
      end
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when ip_end is not an IP" do
      before(:each) do
        subject.stub(:ip_end).and_return("bla")
      end
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when start is greater than end" do
      let(:ip_start) {"127.0.0.2"}
      let(:ip_end) {"127.0.0.1"}
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
  end
end