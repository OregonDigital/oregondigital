source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'

gem 'mail', '~> 2.5.5'
gem 'nokogiri', '~> 1.6.4'
gem 'rest-client', '~> 1.7.3'
gem 'sprockets', '~> 2.11.3'
gem 'yard', '~> 0.9.11'

gem 'responders', '~> 2.0'
gem 'blacklight'
gem 'hydra-head', '6.4.0', :git => 'https://github.com/OregonDigital/hydra-head'
gem 'active-fedora', :git => 'https://github.com/OregonDigital/active_fedora'

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails',   '~> 4.0.4'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails', '~>3.1.4'
gem 'jquery-ui-rails'
gem 'cocoon', '~>1.2.0'

# Nicer form development
gem 'simple_form', '~> 3.0.0'

# Local configs / overrides / etc
gem 'constantinople', '~>0.2.2'

gem "unicode", :platforms => [:mri_18, :mri_19]
gem "bootstrap-sass", '~>2.3.2.0'

gem 'ruby-filemagic', '~>0.4.2'

gem 'rdf', '~>1.1.2.1'
gem 'sparql'
gem 'sparql-client'

gem 'noid'
gem 'hybag'
gem 'qa', :github => "terrellt/questioning_authority", :branch => "feature/od-fixes"

gem 'resque', '~>1.25.0'

gem "ruby-vips", '~>1.0.6'
gem 'rmagick', '~>2.13.2'

gem "devise", "~> 3.1"
gem "devise-guests", "~> 0.3"

# Necessary for target server deployment
gem 'capistrano', '2.15.5'
gem 'capistrano-ext'

# Nice gem for wrapping the most popular jquery file uploader
gem "jquery-fileupload-rails", '~>0.4.1'

# File uploader gem - superior to paperclip in every way!
gem "carrierwave", '~>0.9.0'

gem 'ip-ranges', '~>0.1.1'

# Derivative Creation

gem 'hydra-derivatives'
gem 'mini_magick'

# Docsplit for splitting up documents
gem 'docsplit'

# Recursive open-struct for YAML Datastream
gem 'recursive-open-struct'

# Active Fedora Crosswalks
gem 'active_fedora-crosswalks'

# Hydra Role Management for roles
gem 'hydra-role-management'

# Draper for decoration
gem 'draper'

# Ingest form FBOs
gem 'metadata-ingest-form', '~>2.4'

# mysql gem
gem 'mysql2', '~>0.3.20'

# Unicorn for web server
gem 'puma'

# OAI
gem 'oai', :github => "code4lib/ruby-oai", :branch => :master

# Old Asset Precompile Behavior for Stylesheets
gem "sprockets-digest-assets-fix", :github => "tobiasr/sprockets-digest-assets-fix"

gem 'rdf-mongo', :github => "terrellt/rdf-mongo"
gem 'bson_ext'

# Blacklight Advanced Search
gem 'blacklight_advanced_search', '~> 2.2.0'

# Send email from form
gem 'mail_form'

gem 'newrelic_rpm'

# Dalli for memcache
gem 'dalli'

# Resque-retry for retrying resque jobs
gem 'resque-retry'
gem 'rspec-rails', '~>2.0'

group :development do
  # Spring as Rails preloader
  gem 'spring'
  gem 'pry-remote'
end

group :test do
  gem 'webmock'
  gem 'fakeredis', :require => 'fakeredis/rspec'
  gem 'rspec_junit_formatter', :github => 'circleci/rspec_junit_formatter'
  gem 'capybara-screenshot'
end

group :development, :test do
  # Rspec stuff

  gem 'sqlite3', '~>1.3.7'
  gem 'jettywrapper'

  # Form testing
  gem 'capybara'
  gem 'poltergeist'

  # Exif stuff - regardless of our image library, we want tests to access image data
  gem 'exifr', '~>1.1.3'

  # Coveralls to announce our test coverage
  gem 'coveralls', require: false

  # Factories to make our "let" blocks DRY
  gem "factory_girl_rails", :require => false

  # Make JS testing work while keeping the DB clean
  gem "database_cleaner"

  gem 'pry'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'shoulda'
end
