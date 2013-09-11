RSpec.configure do |config|
  # Pull in devise helpers for testing auth
  config.include Devise::TestHelpers, :type => :controller
end