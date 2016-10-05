RSpec.configure do |config|

  config.before(:each) do
    r = $redis
    keys = r.keys
    r.del *keys if keys.length > 0
  end
end
