class ContactForm < MailForm::Base
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :phone
  attribute :location
  attribute :message,   :validate => true
  attribute :item
  attribute :contact_method,  :captcha  => true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "OregonDigital Contact Form",
      :to => "dsc@uoregon.edu",
      :from => %("#{name}" <#{email}>)
    }
  end
end
