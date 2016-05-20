# frozen_string_literal: true

class GroupInvitation < ActiveRecord::Base
  belongs_to :group
end
