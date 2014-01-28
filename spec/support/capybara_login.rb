def capybara_login(user)
  current = current_path
  visit root_path
  click_link "Login"
  fill_in "Email", :with => user.email
  fill_in "Password", :with => user.password
  click_button "Sign in"
  visit current if current
end