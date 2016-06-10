require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Xikolo < OmniAuth::Strategies::OAuth2
      option :name, :xikolo

      option :client_options, {
          site: 'http://localhost:3001',
          authorize_url: '/oauth/authorize'
      }

      uid { raw_info['id'] }

      info do
        {
            email: raw_info['email'],
            first_name: raw_info['first_name'],
            last_name: raw_info['last_name'],
            image: 'http://localhost:3000' + '/avatar/' + raw_info['id']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/user').parsed
        puts @raw_info
        @raw_info
      end
    end
  end
end
