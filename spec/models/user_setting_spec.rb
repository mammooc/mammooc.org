# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserSetting, type: :model do
  let(:setting) { FactoryGirl.create :user_setting }
  describe 'value(key)' do
    let(:setting_entry) { FactoryGirl.create :user_setting_entry, setting: setting }

    it 'returns an existing value' do
      expect(setting.value(setting_entry.key)).to eq setting_entry.value
    end

    it 'returns nil if an UserSettingsEntry with the given key does not exist' do
      expect(setting.value(:notexisting_key)).to be_nil
    end
  end

  describe 'set(key, value)' do
    context 'new UserSettingsEntry' do
      let(:key) { 'key' }
      let(:value) { 'value' }

      it 'creates new UserSettingsEntry' do
        expect { setting.set(key, value) }.to change { UserSettingEntry.count }.by(1)
      end

      it 'saves with correct value' do
        expect { setting.set(key, value) }.to change { setting.value(key) }.from(nil).to(value)
      end

      context 'value is Array' do
        let(:value) { [1, 2, 3] }

        it 'saves with correct value' do
          expect { setting.set(key, value) }.to change { setting.value(key) }.from(nil).to(value)
        end
      end
    end

    context 'existing UserSettingsEntry' do
      let(:old_value) { 'old value' }
      let(:new_value) { 'new value' }
      let(:setting_entry) { FactoryGirl.create :user_setting_entry, setting: setting, value: old_value }

      it 'overwrites the old value' do
        expect { setting.set(setting_entry.key, new_value) }.to change { setting.value(setting_entry.key) }.from(old_value)
          .to(new_value)
      end
    end
  end
end
