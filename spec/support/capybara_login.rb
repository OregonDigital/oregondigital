def capybara_login(user)
  current = current_path
  visit root_path
  within(".navbar") do
    click_link "Login"
  end
  fill_in "Email", :with => user.email
  fill_in "Password", :with => user.password
  click_button "Sign in"
  visit current if current
end
