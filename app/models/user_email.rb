# -*- encoding : utf-8 -*-
class UserEmail < ActiveRecord::Base

  LCHARS    = /\w+\p{L}\p{N}\-\!\/#\$%&'*+=?^`{|}~}/
  LOCAL     = /[#{LCHARS.source}]+(\.[#{LCHARS.source}]+)*/
  DCHARS    = /A-z\d/
  SUBDOMAIN = /[#{DCHARS.source}]+(\-+[#{DCHARS.source}]+)*/
  DOMAIN    = /#{SUBDOMAIN.source}(\.#{SUBDOMAIN.source})*\.[#{DCHARS.source}]{2,}/
  EMAIL     = /\A#{LOCAL.source}@#{DOMAIN.source}\z/i


  belongs_to :user
  validates_uniqueness_of :address, scope: :user_id
  validates_uniqueness_of :is_primary, scope: :user_id
  validates :address, presence:   true,
            uniqueness: {case_sensitive: false},
            format:     {with: EMAIL}
  # validates_presence_of :is_verified
end
