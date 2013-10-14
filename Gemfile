source 'https://rubygems.org'

gem 'blacklight'
gem 'hydra-head', '6.3.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails', '~>3.0.4'
gem 'cocoon', '~>1.2.0'

# Nicer form development
gem 'simple_form', '~>2.1.0'

# Local configs / overrides / etc
gem 'constantinople', '~>0.2.2'

gem "unicode", :platforms => [:mri_18, :mri_19]
gem "bootstrap-sass", '~>2.3.2.0'

gem 'libv8', '~> 3.11.8'
gem 'therubyracer', :require => 'v8'
gem 'ruby-filemagic', '~>0.4.2'

gem 'noid', '~>0.6.6'
gem 'hybag'

gem 'resque', '~>1.24.1'

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

gem 'hydra-derivatives'

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

group :development do
  gem 'pry', '~>0.9.12.2'
  gem 'pry-doc', '~>0.4.6'
  gem 'pry-debugger', '~>0.2.2'
  gem 'pry-rails', '~>0.3.1'
  # Spring as Rails preloader
  gem 'spring'
  # Guard for auto-test running
  gem 'guard'
  gem 'guard-rspec'
  gem 'unicorn', '~>4.6.3'
end

group :development, :test do
  # Rspec stuff
  gem 'rspec-rails'
  gem 'rspec-steps'

  gem 'sqlite3', '~>1.3.7'
  gem 'jettywrapper'

  # Form testing
  gem 'capybara', '~>2.0'
  gem 'poltergeist', '~>1.1.0'

  # Exif stuff - regardless of our image library, we want tests to access image data
  gem 'exifr', '~>1.1.3'

  # Coveralls to announce our test coverage
  gem 'coveralls', require: false

  # Factories to make our "let" blocks DRY
  gem "factory_girl_rails"
end
