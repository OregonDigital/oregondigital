require 'spec_helper'

describe "Sending an email via the Contact Form" do

#  before do
#    sign_in :user_with_fixtures
#  end

  it "should send mail" do
    ContactForm.any_instance.stub(:deliver).and_return(true)
    visit '/'
    click_link "Contact"
    page.should have_content "Contact"
    page.should have_content "use the following form to send us feedback"
    fill_in "contact_form_name", with: "Test McPherson" 
    fill_in "contact_form_email", with: "archivist1@example.com"
    fill_in "contact_form_message", with: "I am contacting you regarding OregonDigital."
    click_button "Send Message"
    page.should have_content "Thank you"
    # this step allows the delivery to go back to normal
    ContactForm.any_instance.unstub(:deliver)
  end


  it "should give an error when I don't provide a valid email" do
    visit '/'
    click_link "Contact"
    page.should have_content "Contact"
    page.should have_content "use the following form to send us feedback"
    fill_in "contact_form_name", with: "Test McPherson" 
    fill_in "contact_form_email", with: "archivist1"
    fill_in "contact_form_message", with: "I am contacting you regarding OregonDigital"
    click_button "Send Message"
    page.should have_content "Sorry, this message was not sent successfully"
  end

  it "should give an error when I don't provide a name" do
    visit '/'
    click_link "Contact"
    page.should have_content "Contact"
    page.should have_content "use the following form to send us feedback"
    fill_in "contact_form_email", with: "archivist1@example.com"
    fill_in "contact_form_message", with: "I am contacting you regarding OregonDigital"
    click_button "Send Message"
    page.should have_content "Sorry, this message was not sent successfully"
  end

  it "should give an error when I don't provide a message" do
    visit '/'
    click_link "Contact"
    page.should have_content "Contact"
    page.should have_content "use the following form to send us feedback"
    fill_in "contact_form_name", with: "Test McPherson" 
    fill_in "contact_form_email", with: "archivist1@example.com"
    click_button "Send Message"
    page.should have_content "Sorry, this message was not sent successfully"
  end

  it "should give an error when I provide an invalid captcha" do
    visit '/'
    click_link "Contact"
    page.should have_content "Contact"
    page.should have_content "use the following form to send us feedback"
    fill_in "contact_form_contact_method", with: "My name is" 
    fill_in "contact_form_name", with: "Test McPherson" 
    fill_in "contact_form_email", with: "archivist1@example.com"
    fill_in "contact_form_message", with: "I am contacting you regarding OregonDigital."
    click_button "Send Message"
    page.should have_content "Sorry, this message was not sent successfully"
  end
end
