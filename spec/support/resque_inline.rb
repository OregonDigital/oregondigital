RSpec.configure do |config|
  config.before(:each) do
    Resque.inline = (example.metadata[:resque] == true)
  end
end
