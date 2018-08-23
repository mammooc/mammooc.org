# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

# In order to deliver the latest versions of our translations, we need to export them first.
Rake::Task['assets:precompile'].enhance ['i18n:js:export']
