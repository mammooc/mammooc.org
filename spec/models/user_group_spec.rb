# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserGroup, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group, users: [user]) }

  describe 'set is admin' do
    it 'sets attribute is_admin to true' do
      described_class.set_is_admin(group.id, user.id, true)
      admin_ids = described_class.where(group_id: group.id, is_admin: true).collect(&:user_id)
      expect(admin_ids).to include(user.id)
    end

    it 'sets attribute is_admin to false' do
      described_class.set_is_admin(group.id, user.id, true)
      described_class.set_is_admin(group.id, user.id, false)
      admin_ids = described_class.where(group_id: group.id, is_admin: true).collect(&:user_id)
      expect(admin_ids).not_to include(user.id)
    end
  end
end
