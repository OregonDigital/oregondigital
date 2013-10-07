require 'spec_helper'

describe "admin panel links" do
  let(:basic_user) {
    u = User.new
    u.email = "test@test.com"
    u.password = "password"
    u
  }
  before(:each) do
    user
    visit root_path
  end
  context "when a user is logged in" do
    let(:user) {basic_user}
    context "and they are an admin" do
      let(:user) do
        u = basic_user
        r = Role.new
        r.name = 'admin'
        r.save
        u.roles << r
        u.save
        u
      end
      before(:each) do
        capybara_login(user)
      end
      it "should display a roles link" do
        expect(page).to have_link("Roles")
      end
    end
    context "and they are not an admin" do
      it "should not display a roles link" do
        expect(page).not_to have_link("Roles")
      end
    end
  end
end