# frozen_string_literal: true

class MoocProviderUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :mooc_provider
end
