require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class OpenHPI < OmniAuth::Strategies::OAuth2
      option :name, 'openHPI'

      option :client_options, {
          site: 'https://open.hpi.de',
          authorize_url: '/oauth/authorize'
      }

      uid { raw_info['id'] }

      info do
        {
            email: raw_info['email'],
            first_name: raw_info['first_name'],
            last_name: raw_info['last_name'],
            image: 'https://open.hpi.de' + '/avatar/' + raw_info['id']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/api/user').parsed
      end
    end
  end
end
