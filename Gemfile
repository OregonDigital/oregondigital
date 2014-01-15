source 'https://rubygems.org'

gem 'rails', '~> 4.0.0'
gem 'blacklight'
gem 'hydra-head', '6.4.0'

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails', '~>3.0.4'
gem 'cocoon', '~>1.2.0'

# Nicer form development
gem 'simple_form', '~> 3.0.0'

# Local configs / overrides / etc
gem 'constantinople', '~>0.2.2'

gem "unicode", :platforms => [:mri_18, :mri_19]
gem "bootstrap-sass", '~>2.3.2.0'

gem 'therubyracer'
gem 'ruby-filemagic', '~>0.4.2'

gem 'rdf', '~>1.1.0.1'
gem 'linkeddata'
gem 'rdf-redis', '~>0.0.2', :git => 'git://github.com/no-reply/rdf-redis.git'

gem 'noid', '~>0.6.6'
gem 'hybag'
gem 'qa', '~>0.0.3', :git => "git://github.com/jechols/questioning_authority"

gem 'resque', '~>1.25.0'

gem "ruby-vips", '~>0.3.6'
gem 'rmagick', '~>2.13.2'

gem "devise"
gem "devise-guests", "~> 0.3"

# Nice gem for wrapping the most popular jquery file uploader
gem "jquery-fileupload-rails", '~>0.4.1'

# File uploader gem - superior to paperclip in every way!
gem "carrierwave", '~>0.9.0'

gem 'ip-ranges', '~>0.1.1'

# Derivative Creation

gem 'hydra-derivatives', '0.0.5'

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
gem 'metadata-ingest-form', :git => "git://github.com/OregonDigital/metadata-ingest-form.git"

# mysql gem
gem 'mysql2'

# Unicorn for web server
gem 'unicorn', '~>4.6.3'

# OAI
gem 'oai'

group :development do
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-debugger'
  gem 'pry-rails'
  # Spring as Rails preloader
  gem 'spring'
  # Guard for auto-test running
  gem 'guard', '~>1.0'
  gem 'guard-rspec', '~>3.0'
end

group :test do
  gem 'webmock'
end

group :development, :test do
  # Rspec stuff
  gem 'rspec-rails', '~>2.14.0'

  gem 'sqlite3', '~>1.3.7'
  gem 'jettywrapper'

  # Form testing
  gem 'capybara', '~>2.1'
  gem 'poltergeist', '~>1.5.0'

  # Exif stuff - regardless of our image library, we want tests to access image data
  gem 'exifr', '~>1.1.3'

  # Coveralls to announce our test coverage
  gem 'coveralls', require: false

  # Factories to make our "let" blocks DRY
  gem "factory_girl_rails", :require => false
end
