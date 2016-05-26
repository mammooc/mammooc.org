# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Google < OmniAuth::Strategies::GoogleOauth2
      option :name, 'google'
    end
  end
end
