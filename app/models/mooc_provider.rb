# -*- encoding : utf-8 -*-
class MoocProvider < ActiveRecord::Base
  has_many :courses
  has_many :users, through: :mooc_provider_users
  has_many :user_dates
  validates :name, uniqueness: true
  validates :logo_id, presence: true
  enum api_support_state: [:oauth, :naive, :nil]

  def self.options_for_select
    order('LOWER(name)').map {|provider| [provider.name, provider.id] }
  end
end
