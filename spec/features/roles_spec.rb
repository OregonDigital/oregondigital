require 'spec_helper'

describe "Role management" do
  let(:user) { FactoryGirl.create(:admin) }

  before(:each) do
    capybara_login(user)
    visit root_path

    within(".utils .admin") do
      click_link "Roles"
    end
  end

  it "should allow an admin to create a role" do
    click_button "Create a new role"
    fill_in "Role name", :with => "foo"
    click_button "Create Role"

    # We have two because the factory created one for us to use with login
    expect(Role.count).to eq(2)
    expect(Role.first.name).to eq("admin")
    expect(Role.last.name).to eq("foo")
  end
end
