RSpec.configure do |config|
  config.before(:each) do |example|
    Resque.inline = (example.metadata[:resque] == true)
  end
end
