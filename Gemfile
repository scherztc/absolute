source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.4'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'mysql2'  # used on sandbox

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'curate', github:'ndlib/curate'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano', group: :development
gem 'capistrano-rails', group: :development
gem 'capistrano-bundler', group: :development
# don't use capistrano-ext, which only works with Capistrano 2

# Use debugger
# gem 'debugger', group: [:development, :test]

gem "unicode", platforms: [:mri_18, :mri_19]
gem "bootstrap-sass"
gem "devise"
gem "devise-guests", "~> 0.3"
gem 'hydra-role-management', '0.1.0'
gem 'riiif', '0.0.6'
gem 'hydra-admin-collections', github: 'bmaddy/hydra-admin-collections', branch: 'more_attrs'

group :development, :test do
  gem "rspec-rails"
  gem 'factory_girl_rails'
  gem 'equivalent-xml'
  gem 'capybara'
  gem "jettywrapper"
end
