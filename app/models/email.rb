# -*- encoding : utf-8 -*-
class Email < ActiveRecord::Base
  belongs_to :user
end
