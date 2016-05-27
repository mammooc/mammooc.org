require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Xikolo < OmniAuth::Strategies::OAuth2
      option :name, :xikolo

      option :client_options, {
          :site => "http://localhost:3001",
          :authorize_url => "/oauth/authorize"
      }

      uid { raw_info["id"] }

      info do
        {
            :email => raw_info["email"]
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/user').parsed
      end
    end
  end
end
