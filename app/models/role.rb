class Role < ActiveRecord::Base
  has_many :ip_ranges
end