class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  include OregonDigital::GuestUser
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  layout 'blacklight'

  protect_from_forgery

  # Copied from hydra controller behaviors
  rescue_from Hydra::AccessDenied do |exception|
    if (exception.action == :edit)
      redirect_to({:action=>'show'}, :alert => exception.message)
    elsif current_user and current_user.persisted?
      redirect_to root_url, :alert => exception.message
    else
      session["user_return_to"] = request.url
      redirect_to new_user_session_url, :alert => exception.message
    end
  end
end
