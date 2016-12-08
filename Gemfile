# encoding: utf-8
# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.1'
# Use sqlite3 as the database for Active Record
gem 'pg'
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'slim-rails'
gem 'redcarpet'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '<6.0.0' # course autocompletion bug if higher version

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Phusion Passenger 5 as the app server
gem 'passenger'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# authentication
gem 'devise'
gem 'oauth2'
gem 'omniauth'
gem 'omniauth-oauth2'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-github'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-twitter'
gem 'omniauth-windowslive'
gem 'omniauth-amazon'

# authorization
gem 'cancancan'

# HTTP api_connection
gem 'rest-client'

# file upload
gem 'paperclip'

# amazon S3 connection
gem 'aws-sdk'

# cron job
gem 'redis'
gem 'sidekiq'
gem 'whenever'

# newsfeed
gem 'public_activity'

gem 'bootstrap-sass'
gem 'font-awesome-sass'

gem 'bootstrap_tokenfield_rails'
gem 'bootstrap-datepicker-rails'

gem 'factory_girl_rails'

gem 'rails-i18n'
gem 'i18n-js'

gem 'http_accept_language'

gem 'config'

gem 'newrelic_rpm'

# for filtering, searching and sorting
gem 'filterrific', '2.0.5'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# for ical-Feed
gem 'icalendar'

#calendar widget
gem 'fullcalendar-rails'
gem 'momentjs-rails'

# support for Cross-Origin Resource Sharing (CORS)
gem 'rack-cors', require: 'rack/cors'
# Secure Headers
gem 'secure_headers'

# consume JSON API
gem 'json-api-vanilla'

# consume JSON API
gem 'json-api-vanilla'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'ruby-debug-passenger'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails'
  gem 'rspec_junit_formatter'

  gem 'bootstrap-generators'

  gem 'capybara'
  gem 'capybara-selenium'
  gem 'database_cleaner'
  gem 'rails-controller-testing', require: false

  # Run selenium tests headless
  gem 'headless'
  gem 'poltergeist'

  gem 'simplecov', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'coveralls', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end
