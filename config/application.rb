require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MAMMOOC
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # necessary for gem to use locales in javascript
    config.assets.initialize_on_precompile = true

    # Load the files in lib
    config.autoload_paths  = %W(#{config.root}/lib)

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.to_prepare do
      Devise::SessionsController.skip_before_action :require_login
      Devise::PasswordsController.skip_before_action :require_login
      Devise::UnlocksController.skip_before_action :require_login
      Devise::ConfirmationsController.skip_before_action :require_login
      Devise::RegistrationsController.skip_before_action :require_login
    end

    config.generators do |g|
      g.test_framework :rspec
    end

    config.serve_static_files = true

    config.action_mailer.default_url_options = {:host => Settings.default_hostname}
  end
end
