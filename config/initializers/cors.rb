# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/evaluations/export*', headers: :any, methods: [:get]
  end

  allow do
    origins Settings.root_url

    resource '/api/current_user_with_evaluation*', headers: :any, methods: [:get]
    resource '/evaluations/save*', headers: :any, methods: [:get]
  end
end
