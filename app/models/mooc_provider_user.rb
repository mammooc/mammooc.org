# -*- encoding : utf-8 -*-
class MoocProviderUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :mooc_provider
end
