RSpec.configure do |config|
  config.before(:each) do
    Resque.inline = true
  end
end