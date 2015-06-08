# -*- encoding : utf-8 -*-
require 'redis'
require 'sidekiq'

# Prevent starting this redis-server on heroku
if defined?(PhusionPassenger) && ENV['AUTO_START_SIDEKIQ']
  PhusionPassenger.on_event(:starting_worker_process) do |_forked|
    @redis_pid ||= spawn('redis-server')
  end
end
