require 'spec_helper'

describe "IP Range Administration" do
  let(:user) { FactoryGirl.create(:user) }
  let(:role) { FactoryGirl.create(:role, name: "admin") }

  describe "edit role" do
    context "when a user is logged in" do
      before(:each) do
        visit root_path
        capybara_login(user)
      end
      context "and they are a user" do
        it "should not let them to the role admin page" do
          expect{visit role_management.edit_role_path(role)}.to raise_error(CanCan::AccessDenied)
        end
      end
      context "and they are an admin" do
        before(:each) do
          user.roles << role
          user.save
        end
        context "and they try to delete the role" do
          let(:new_role) { FactoryGirl.create(:role, name: "test") }
          before(:each) do
            visit role_management.edit_role_path(new_role)
            within('.edit_role') do
              click_link "Delete"
            end
          end
          it "should delete the role" do
            expect(page).to have_content("Role was successfully deleted.")
          end
        end
        context "and they try to add IP ranges to a role" do
          before(:each) do
            visit role_management.edit_role_path(role)
            within("#ip-ranges") do
              fill_in :ip_range_start, :with => "127.0.0.1"
              fill_in :ip_range_end, :with => "127.0.0.1"
              click_button "Add"
            end
          end
          it "should work" do
            within("#ip-ranges") do
              expect(page).to have_content("127.0.0.1 - 127.0.0.1")
            end
          end
          context "and they try to delete the IP range they added" do
            before(:each) do
              within("#ip-ranges") do
                click_button("Remove Range")
              end
            end
            it "should work" do
              within("#ip-ranges") do
                expect(page).not_to have_content("127.0.0.1 - 127.0.0.1")
              end
            end
          end
        end
      end
    end
  end
end
