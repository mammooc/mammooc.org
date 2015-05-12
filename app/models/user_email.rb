# -*- encoding : utf-8 -*-
class UserEmail < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :address, scope: :user_id
  validates_uniqueness_of :is_primary, scope: :user_id
  validates_presence_of :is_verified
end
