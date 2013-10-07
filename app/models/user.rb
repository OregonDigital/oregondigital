class User < ActiveRecord::Base
# Connects this user object to Hydra behaviors.
 include Hydra::User
 # Connects this user object to Role-management behaviors.
 include Hydra::RoleManagement::UserRoles
 # Includes IP-oriented groups
 include OregonDigital::IpGroups

# Connects this user object to Blacklights Bookmarks.
 include Blacklight::User
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end
end
