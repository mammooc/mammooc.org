# frozen_string_literal: true

module Api
  module V1
    class OrganisationResource < JSONAPI::Resource
      immutable

      attributes :name, :url, :created_at, :updated_at
    end
  end
end
