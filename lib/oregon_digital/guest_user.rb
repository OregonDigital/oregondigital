module OregonDigital
  module GuestUser
    extend ActiveSupport::Concern
    def create_guest_user(email = nil)
      u = super
      u.update_attributes(:current_sign_in_ip => request.remote_ip)
      u
    end

    def guest_user
      u = super
      u.update_attributes(:current_sign_in_ip => request.remote_ip)
      u
    end

    def current_ability
      @current_ability ||= ::Ability.new(current_or_guest_user)
    end

  end
end
