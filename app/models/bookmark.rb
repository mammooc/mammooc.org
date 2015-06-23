# -*- encoding : utf-8 -*-
class Bookmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  include PublicActivity::Common
end
