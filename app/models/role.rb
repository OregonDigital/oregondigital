# This is pulled from the Hydra-Role-Management gem and modified. Need to update upstream to use a module
# to make this easily extendable.
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :ip_ranges

  validates :name,
            uniqueness: true,
            format: { with: /\A[a-zA-Z0-9._-]+\z/,
                      :message => "Only letters, numbers, hyphens, underscores and periods are allowed"}

end