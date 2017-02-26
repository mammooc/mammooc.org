# frozen_string_literal: true

module Api
  module V1
    class MoocProviderResource < JSONAPI::Resource
      immutable

      attributes :logo_id, :name, :url, :description, :created_at, :updated_at, :api_support_state, :oauth_path_for_login
    end
  end
end
