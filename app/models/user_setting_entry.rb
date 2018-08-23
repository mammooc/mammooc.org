# frozen_string_literal: true

class UserSettingEntry < ApplicationRecord
  belongs_to :setting, class_name: 'UserSetting', foreign_key: 'user_setting_id', inverse_of: :entries

  serialize :value, Object
end
