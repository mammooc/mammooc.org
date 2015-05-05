# -*- encoding : utf-8 -*-
class Progress < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
end
