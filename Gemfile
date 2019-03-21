# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.1.1'
# Use sqlite3 as the database for Active Record
gem 'pg'
gem 'sass-rails', '>= 5.0.7'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '>= 4.2.2'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'redcarpet'
gem 'slim-rails', '>= 3.1.3'

# Use jquery as the JavaScript library
gem 'jquery-rails', '>= 4.3.3'
gem 'jquery-ui-rails', '>= 6.0.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Phusion Passenger 5 as the app server
gem 'passenger', '>= 5.3.4'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# authentication
gem 'devise', '>= 4.6.0'
gem 'oauth2', '>= 1.4.0'
gem 'omniauth', '>= 1.8.1'
gem 'omniauth-amazon', '>= 1.0.1'
gem 'omniauth-facebook', '>= 5.0.0'
gem 'omniauth-github', '>= 1.3.0'
gem 'omniauth-google-oauth2', '>= 0.5.3'
gem 'omniauth-linkedin-oauth2', '>= 0.2.5'
gem 'omniauth-oauth2', '>= 1.5.0'
gem 'omniauth-twitter', '>= 1.4.0'
gem 'omniauth-windowslive', '>= 0.0.12'

# authorization
gem 'cancancan'

# HTTP api_connection
gem 'rest-client'

# file upload
gem 'paperclip'

# amazon S3 connection
gem 'aws-sdk-s3'

# cron job
gem 'redis'
gem 'sidekiq', '>= 5.2.1'
gem 'whenever'

# newsfeed
gem 'public_activity', '>= 1.6.2'

gem 'bootstrap-sass'
gem 'font-awesome-sass'

gem 'bootstrap-datepicker-rails', '>= 1.8.0.1'
gem 'bootstrap_tokenfield_rails'

gem 'factory_bot_rails', '>= 4.11.0'

gem 'i18n-js'
gem 'rails-i18n', '>= 5.1.1'

gem 'http_accept_language'

gem 'config'

gem 'newrelic_rpm'

# for filtering, searching and sorting
gem 'filterrific'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# for ical-Feed
gem 'icalendar'

# calendar widget
gem 'fullcalendar-rails', '>= 3.9.0.0'
gem 'momentjs-rails', '>= 2.20.1'

# support for Cross-Origin Resource Sharing (CORS)
gem 'rack-cors', require: 'rack/cors'
# Secure Headers
gem 'secure_headers'

# JSON API
gem 'json-api-vanilla'
gem 'jsonapi-resources', '>= 0.9.3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'ruby-debug-passenger'

  # Listen for file system changes
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails', '>= 3.8.0'
  gem 'rspec_junit_formatter'

  gem 'bootstrap-generators', '>= 3.3.4'

  gem 'capybara', '>= 3.6.0'
  gem 'capybara-selenium', '>= 0.0.6'
  gem 'database_cleaner'
  gem 'rails-controller-testing', '>= 1.0.2', require: false

  # Run selenium tests headless
  gem 'headless'
  gem 'poltergeist', '>= 1.18.1'

  gem 'coveralls', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false

  gem 'pry'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 3.6.2'
end
