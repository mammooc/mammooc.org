# encoding: utf-8
# frozen_string_literal: true
require 'sidekiq'

uri = URI.parse(ENV['REDIS_PROVIDER'] || 'redis://localhost:6379/')

Sidekiq.configure_server do |config|
  config.redis = {host: uri.host, port: uri.port, password: uri.password}
end

Sidekiq.configure_client do |config|
  config.redis = {host: uri.host, port: uri.port, password: uri.password}
end

if defined?(PhusionPassenger) && ENV['AUTO_START_SIDEKIQ'] == 'true'
  PhusionPassenger.on_event(:starting_worker_process) do |_forked|
    @sidekiq_pid ||= spawn('bundle exec sidekiq -C ./config/sidekiq.yml')
  end
end
