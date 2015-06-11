class UserSetting < ActiveRecord::Base
  belongs_to :user
  has_many :entries, class_name: 'UserSettingEntry', dependent: :destroy

  def value(key)
    entry = self.entries.find_by(key: key)
    if entry
      return entry.value
    else
      return nil
    end
  end

  def set(key, value)
    entry = self.entries.find_by(key: key) || UserSettingEntry.new(key: key, setting: self)
    entry.value = value
    entry.save!
  end
end
