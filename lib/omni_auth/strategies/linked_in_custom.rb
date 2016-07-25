# frozen_string_literal: true

module OmniAuth
  module Strategies
    class LinkedInCustom < OmniAuth::Strategies::LinkedIn
      option :name, 'linkedin'

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
