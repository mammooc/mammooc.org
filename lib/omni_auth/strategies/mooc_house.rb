# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class MoocHouse < OmniAuth::Strategies::OAuth2
      option :name, 'moochouse'

      option :client_options, site: 'https://mooc.house',
                              authorize_url: '/oauth/authorize'

      uid { raw_info['id'] }

      info do
        {
          email: raw_info['email'],
          first_name: raw_info['first_name'],
          last_name: raw_info['last_name'],
          image: 'https://mooc.house' + '/avatar/' + raw_info['id']
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

OmniAuth.config.add_camelization 'moochouse', 'mooc.house'
