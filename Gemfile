source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'mysql2'  # used on sandbox

# two gems required for oracle database connection
gem 'activerecord-oracle_enhanced-adapter'
gem 'ruby-oci8'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
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
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use Capistrano for deployment
gem 'capistrano', '~> 3.1',           group: :development
gem 'capistrano-rails', '~> 1.1',     group: :development
gem 'capistrano-bundler', '~> 1.1.2', group: :development

gem 'coveralls', require: false, group: :test
#gem 'worthwhile', '0.1.1'
gem 'worthwhile', github: 'projecthydra-labs/worthwhile', ref: 'adbb1'

gem 'hydra', '7.1.0'

gem "bootstrap-sass"
gem 'hydra-role-management', '0.1.0'
gem 'hydra-remote_identifier'
gem 'riiif', '0.0.9'
gem 'openseadragon'
gem 'angularjs-rails'
gem 'blacklight_advanced_search'
gem 'blacklight_range_limit'

gem 'language_list'

gem "devise"
gem "devise-guests", "~> 0.3"
gem 'devise_cas_authenticatable', '~> 1.3.6'

gem 'resque-scheduler'

group :development, :test do
  gem "jettywrapper"
  gem "rspec-rails", '~> 3.1'
  gem "rspec-its"
end

group :debug do
  gem "pry-rescue"
  gem "pry-stack_explorer"
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'launchy'
end

