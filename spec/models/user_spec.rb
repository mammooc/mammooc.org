# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has valid factory' do
    expect(FactoryGirl.build_stubbed(:user)).to be_valid
  end

  it 'requires first name' do
    expect(FactoryGirl.build_stubbed(:user, first_name: '')).not_to be_valid
  end

  it 'requires last name' do
    expect(FactoryGirl.build_stubbed(:user, last_name: '')).not_to be_valid
  end

  it 'requires email' do
    expect(FactoryGirl.build_stubbed(:user, email: '')).not_to be_valid
  end

  describe 'common_groups_with_user(other_user)' do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    it 'should only display common groups' do
      group1 = FactoryGirl.create(:group, users: [user])
      group2 = FactoryGirl.create(:group, users: [user, other_user])
      expect(user.common_groups_with_user(other_user)).to match([group2])
    end

    it 'should display all groups if they are equal' do
      group1 = FactoryGirl.create(:group, users: [user, other_user])
      group2 = FactoryGirl.create(:group, users: [user, other_user])
      expect(user.common_groups_with_user(other_user)).to match_array([group1, group2])
    end

    it 'should be empty if there are no common groups' do
      group1 = FactoryGirl.create(:group, users: [user])
      group2 = FactoryGirl.create(:group, users: [other_user])
      expect(user.common_groups_with_user(other_user)).to match([])
    end

  end
end
