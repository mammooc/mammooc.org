# -*- encoding : utf-8 -*-
class MoocProvider < ActiveRecord::Base
  has_many :courses
  has_many :users, through: :mooc_provider_users
  validates :name, uniqueness: true
  validates :logo_id, presence: true
end
