require 'spec_helper'

describe "admin panel links" do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }

  before(:each) do
    visit root_path
  end
  context "when a user is logged in" do
    context "and they are an admin" do
      before(:each) do
        capybara_login(admin)
      end
      it "should display a roles link" do
        expect(page).to have_link("Roles")
      end
    end
    context "and they are not an admin" do
      before(:each) do
        capybara_login(user)
      end
      it "should not display a roles link" do
        expect(page).not_to have_link("Roles")
      end
    end
  end
end
