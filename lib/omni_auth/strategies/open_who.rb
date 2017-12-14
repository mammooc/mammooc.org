# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class OpenWHO < OmniAuth::Strategies::OAuth2
      option :name, 'openwho'

      option :client_options, site: 'https://openwho.org',
                              authorize_url: '/oauth/authorize'

      uid { raw_info['id'] }

      info do
        {
          email: raw_info['email'],
          first_name: raw_info['first_name'],
          last_name: raw_info['last_name'],
          image: 'https://openwho.org' + '/avatar/' + raw_info['id']
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

OmniAuth.config.add_camelization 'openwho', 'openWHO'
