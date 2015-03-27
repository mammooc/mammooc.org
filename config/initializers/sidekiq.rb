require 'sidekiq'

uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/")

Sidekiq.configure_server do |config|
  config.redis = { host: uri.host, port: uri.port }
end

Sidekiq.configure_client do |config|
  config.redis = { host: uri.host, port: uri.port }
end