# frozen_string_literal: true

class MoocProviderUser < ApplicationRecord
  belongs_to :user
  belongs_to :mooc_provider
end
