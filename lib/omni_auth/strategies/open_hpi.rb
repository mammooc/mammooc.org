# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class OpenHPI < OmniAuth::Strategies::OAuth2
      option :name, 'openhpi'

      option :client_options, site: 'https://open.hpi.de',
                              authorize_url: '/oauth/authorize'

      uid { raw_info['id'] }

      info do
        {
          email: raw_info['email'],
          name: raw_info['full_name'],
          image: raw_info['avatar_url']
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/api/user').parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

OmniAuth.config.add_camelization 'openhpi', 'openHPI'
