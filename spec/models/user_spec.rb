require 'spec_helper'

describe User do
  subject(:user) do
    u = User.new
    u.email = "test@test.org"
    u.password = "testing123"
    u
  end
  describe ".groups" do
    context "when nothing has been assigned" do
      it "should return a blank array" do
        expect(subject.groups).to eq []
      end
    end
    context "immediately after saving" do
      before(:each) do
        subject.save!
      end
      it "should return the 'registered' group" do
        expect(subject.groups).to eq ["registered"]
      end
    end
    context "when the user has a role assigned directly" do
      let(:role) do
        r = Role.new
        r.name = "admin"
        r
      end

      before(:each) do
        role.save!
        subject.roles << role
        subject.save!
      end
      it "should return directly assigned groups" do
        expect(subject.groups.sort).to eq ["admin", "registered"]
      end
    end
    context "when the user has a current sign in IP" do
      before(:each) do
        subject.stub(:current_sign_in_ip).and_return("127.0.0.1")
      end
      context "and there is an IP Range defined" do
        let(:role) do
          r = Role.new
          r.name = "admin"
          r
        end
        let(:ip_range) do
          i = IpRange.new
          i.ip_start = "127.0.0.1"
          i.ip_end = "127.0.0.1"
          i.role = role
          i
        end
        before(:each) do
          ip_range.save
        end
        context "and it is outside the user's range" do
          before(:each) do
            subject.stub(:current_sign_in_ip).and_return("127.0.0.2")
          end
          it "should return a blank array" do
            expect(subject.groups).to eq []
          end
        end
        context "and it is inside the user's range" do
          it "should return the groups assigned" do
            expect(subject.groups).to eq ["admin"]
          end
          context "and they are assigned that role directly as well" do
            before(:each) do
              subject.roles << role
            end
            it "should return unique names" do
              expect(subject.groups).to eq ["admin"]
            end
          end
          context "and they are assigned a different role" do
            before(:each) do
              r = Role.new
              r.name = "test"
              subject.roles << r
            end
            it "should return both groups" do
              expect(subject.groups).to eq ["test", "admin"]
            end
          end
        end
      end
    end
  end
end
