# frozen_string_literal: true

class PingController < ApplicationController
  skip_before_action :require_login
  before_action :postgres_connected!
  before_action :redis_connected!

  def index
    render json: {
      message: 'Pong',
      timenow_in_time_zone____: DateTime.now.in_time_zone.to_i,
      timenow_without_timezone: DateTime.now.to_i
    }
  end

  private

  def redis_connected!
    # any unhandled exception leads to a HTTP 500 response.
    Sidekiq.redis(&:info)
  end

  def postgres_connected!
    # any unhandled exception leads to a HTTP 500 response.
    ApplicationRecord.establish_connection
    ApplicationRecord.connection
    raise ActiveRecord::ConnectionNotEstablished unless ApplicationRecord.connected?
  end
end
