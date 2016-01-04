# Coverage
require 'simplecov'

unless ENV['NO_COVERAGE']
  require 'simplecov'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter
  ]
  pid = Process.pid
  SimpleCov.at_exit do
    SimpleCov.result.format! if Process.pid == pid
  end
  SimpleCov.start('rails')
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl_rails'
require 'webmock/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
# Require all the webmocks
Dir[Rails.root.join("spec/webmocks/**/*.rb")].each { |f| require f }
ROOT_PATH = Rails.root.join("spec")
DUMMY_PATH = File.join(ROOT_PATH,"dummies")

# Allow http connections on localhost
WebMock.disable_net_connect!(:allow_localhost => true)

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # NO transactions!  Ruins external (phantomjs) acceptance testing.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Focus settings
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:each) do
    ActiveFedora::Base.delete_all
    Blacklight.solr.delete_by_query "*:*"
    Blacklight.solr.commit
    ActiveFedora::Rdf::Repositories.repositories.each do |name, repository|
      repository.clear!
    end
    begin
      Rails.cache.clear
    rescue
    end
    GC.start
    Resque.redis.keys("*").each do |key|
      Resque.redis.del(key)
    end
  end

  config.after(:suite) do
    FileUtils.rm_rf(Rails.root.join('tmp', 'bags'))
    FileUtils.rm_rf(Rails.root.join('tmp', 'upload-cache'))

    # Apparently delete_all instantiates objects or something, so we need to be
    # sure tests clean up after themselves - a datastream change will
    # completely break testing otherwise
    ActiveFedora::Base.delete_all
  end
end
