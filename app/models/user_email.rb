# -*- encoding : utf-8 -*-
class UserEmail < ActiveRecord::Base
  LCHARS    = /\w+\p{L}\p{N}\-\!\/#\$%&'*+=?^`{|}~}/
  LOCAL     = /[#{LCHARS.source}]+(\.[#{LCHARS.source}]+)*/
  DCHARS    = /A-z\d/
  SUBDOMAIN = /[#{DCHARS.source}]+(\-+[#{DCHARS.source}]+)*/
  DOMAIN    = /#{SUBDOMAIN.source}(\.#{SUBDOMAIN.source})*\.[#{DCHARS.source}]{2,}/
  EMAIL     = /\A#{LOCAL.source}@#{DOMAIN.source}\z/i

  belongs_to :user
  validate :one_primary_address_per_user
  validates :address,
    presence:   true,
    uniqueness: {case_sensitive: false},
    format:     {with: EMAIL}
  # validates_presence_of :is_verified

  private

  def one_primary_address_per_user
    # TODO: check!
    true
  end
end
