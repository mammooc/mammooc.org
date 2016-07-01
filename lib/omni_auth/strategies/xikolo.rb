require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Xikolo < OmniAuth::Strategies::OAuth2
      option :name, :xikolo

      option :client_options, {
          site: 'https://staging.openhpi.de',
          authorize_url: '/oauth/authorize'
      }

      uid { raw_info['id'] }

      info do
        {
            email: raw_info['email'],
            first_name: raw_info['first_name'],
            last_name: raw_info['last_name'],
            image: 'https://staging.openhpi.de' + '/avatar/' + raw_info['id']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/api/user').parsed
      end
    end
  end
end
