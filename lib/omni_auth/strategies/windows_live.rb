# frozen_string_literal: true

module OmniAuth
  module Strategies
    class WindowsLive < OmniAuth::Strategies::Windowslive
      option :name, 'windows_live'
    end
  end
end

OmniAuth.config.add_camelization 'windows_live', 'Windows Live'
