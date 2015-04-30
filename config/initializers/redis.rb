require 'redis'
require 'sidekiq'

# Prevent starting this redis-server on heroku
if defined?(PhusionPassenger) && ENV['HEROKU'].blank?
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    @redis_pid ||= spawn("redis-server")
  end
end
