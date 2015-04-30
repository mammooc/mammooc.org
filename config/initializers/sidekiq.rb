require 'sidekiq'

uri = URI.parse(ENV["REDIS_PROVIDER"] || "redis://localhost:6379/")

Sidekiq.configure_server do |config|
  config.redis = { host: uri.host, port: uri.port, password: uri.password }
end

Sidekiq.configure_client do |config|
  config.redis = { host: uri.host, port: uri.port, password: uri.password }
end
