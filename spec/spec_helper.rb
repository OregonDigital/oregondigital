# Coverage
require 'coveralls'
Coveralls.wear!('rails')

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl_rails'
require 'webmock/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
ROOT_PATH = File.dirname(__FILE__)
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

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  config.before(:each) do
    ActiveFedora::Base.delete_all

    stub_request(:get, "http://sws.geonames.org/5735237/").
      with(:headers => {'Accept'=>'application/n-triples, text/plain;q=0.5, application/n-quads, text/x-nquads, application/ld+json, application/x-ld+json, application/json, text/html;q=0.5, application/xhtml+xml, image/svg+xml, text/n3, text/rdf+n3, application/rdf+n3, application/rdf+xml, application/trig, application/x-trig, application/trix, application/turtle, text/rdf+turtle, text/turtle, application/x-turtle, */*;q=0.1', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => '<http://sws.geonames.org/5735237/> <http://example.org/blah> "blah" .', :headers => {:'Content-Type' => 'application/n-triples'})


    stub_request(:get, "http://dublincore.org/2012/06/14/dctype.rdf").
      with(:headers => {'Accept'=>'application/n-triples, text/plain;q=0.5, application/n-quads, text/x-nquads, application/ld+json, application/x-ld+json, application/json, text/html;q=0.5, application/xhtml+xml, image/svg+xml, text/n3, text/rdf+n3, application/rdf+n3, application/rdf+xml, application/trig, application/x-trig, application/trix, application/turtle, text/rdf+turtle, text/turtle, application/x-turtle, */*;q=0.1', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => '<http://purl.org/dc/dcmitype/Image> <http://example.org/blah> "blah" .', :headers => {:'Content-Type' => 'application/n-triples'})
  end
end
