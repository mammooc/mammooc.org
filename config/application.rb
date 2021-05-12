# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MAMMOOC
  class Application < Rails::Application
    GC::Profiler.enable

    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 5.0 # TODO: Set to 6.1 as soon as possible

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    # config.time_zone = 'Central Time (US & Canada)'
    # config.eager_load_paths << Rails.root.join("extras")

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i[en de]

    # necessary for gem to use locales in javascripts
    config.assets.initialize_on_precompile = true

    # Load the files in lib
    config.autoload_paths += %W[#{config.root}/lib]

    config.to_prepare do
      Devise::SessionsController.skip_before_action :require_login
      Devise::PasswordsController.skip_before_action :require_login
      Devise::UnlocksController.skip_before_action :require_login
      Devise::ConfirmationsController.skip_before_action :require_login
      Devise::RegistrationsController.skip_before_action :require_login
      Devise::OmniauthCallbacksController.skip_before_action :require_login
    end

    config.generators do |generator|
      generator.test_framework :rspec
    end

    config.action_mailer.default_url_options = {host: Settings.root_url}

    # Force SSL for all connections in single-mode
    # Attention: This will also enable HSTS with a max-age for 1 year.
    # To disable, overwrite `config.hsts = 'max-age=0'` below
    # config.force_ssl = true if ENV['FORCE_SSL'] == 'true'

    # Implement Security Headers
    SecureHeaders::Configuration.default do |config|
      config.cookies = {
        secure: true,
        httponly: true,
        samesite: SecureHeaders::OPT_OUT # might lead to problems with the mammooc-rating-widget
      }

      config.csp = {
        # rubocop:disable Lint/PercentStringArray
        default_src: %W['self'],
        object_src: %w['none'],
        # unsafe-eval required by views/courses/index.js.slim for filterrific to work
        script_src: %w['self' js-agent.newrelic.com bam.nr-data.net 'unsafe-eval'],
        img_src: %w['self' data: https:],
        style_src: %w['self' 'unsafe-inline' https:]
        # rubocop:enable Lint/PercentStringArray
      }

      config.hsts = SecureHeaders::OPT_OUT # handled by nginx
      config.referrer_policy = 'strict-origin-when-cross-origin'
    end
  end
end
