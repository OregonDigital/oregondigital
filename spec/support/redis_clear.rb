RSpec.configure do |config|

  config.before(:each) do
    r = Redis.new
    keys = r.keys
    r.del *keys if keys.length > 0
  end
end
