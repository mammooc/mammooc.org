# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'handles Groups when destroyed' do
    let!(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:third_user) { FactoryGirl.create(:user) }
    let(:one_member_group) { FactoryGirl.create(:group, users: [user]) }
    let(:many_members_group) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }

    it 'deletes a user' do
      user_count = described_class.count
      expect(user.destroy).to be_truthy
      expect(described_class.count).to eql(user_count - 1)
    end

    it 'deletes a user and the primary email address' do
      primary_email = user.primary_email
      expect { user.destroy }.to change { UserEmail.count }.by(-1)
      expect(UserEmail.find_by_address(primary_email)).to be_nil
    end

    it 'deletes a user and every email address' do
      FactoryGirl.create(:user_email, user: user, address: 'second@example.com', is_primary: false)
      FactoryGirl.create(:user_email, user: user, address: 'third@example.com', is_primary: false)
      expect(UserEmail.where(user: user.id).size).to eql 3
      expect { user.destroy! }.not_to raise_error
      expect(UserEmail.where(user: user.id).size).to eql 0
    end

    it 'deletes the user and group when user is last member' do
      UserGroup.set_is_admin(one_member_group.id, user.id, true)
      group_count = Group.all.count
      expect(user.destroy).to be_truthy
      expect(Group.all.count).to eql(group_count - 1)
    end

    it 'deletes the user when user is one of many admins' do
      UserGroup.set_is_admin(many_members_group.id, user.id, true)
      UserGroup.set_is_admin(many_members_group.id, second_user.id, true)
      group_count = Group.all.count
      expect(user.destroy).to be_truthy
      expect(Group.all.count).to eql(group_count)
    end

    it 'does not delete the user when user is last admin and there are other members in group ' do
      UserGroup.set_is_admin(many_members_group.id, user.id, true)
      group_count = Group.all.count
      user_count = described_class.count
      expect(user.destroy).to be_falsey
      expect(described_class.count).to eql(user_count)
      expect(Group.all.count).to eql(group_count)
    end
  end

  describe 'handles Evaluations when destroyed' do
    let!(:user) { FactoryGirl.create(:user) }
    let(:evaluation) { FactoryGirl.create(:full_evaluation, user_id: user.id) }

    it 'set all evaluations to anonym and delete user_id' do
      evaluation.save
      expect(user.destroy).to be_truthy
      evaluation.reload
      expect(evaluation.user_id).to be_nil
      expect(evaluation.rated_anonymously).to be_truthy
    end
  end

  describe 'handles Completions (and Certificates) when destroyed' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:completion) { FactoryGirl.create(:full_completion, user_id: user.id) }

    it 'deletes all comlpetions and the associated certificates' do
      expect(Completion.count).to eql 1
      expect(Certificate.count).to eql 3
      expect(user.destroy).to be_truthy
      expect(Completion.count).to eql 0
      expect(Certificate.count).to eql 0
    end
  end

  describe 'handle recommendations when destroyed' do
    let(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, users: [user, second_user]) }

    it 'deletes recommendations where user is author' do
      FactoryGirl.create(:user_recommendation, author: user)
      FactoryGirl.create(:group_recommendation, author: user)
      FactoryGirl.create(:group_recommendation)
      expect(Recommendation.count).to eq 3
      expect { user.destroy! }.not_to raise_error
      expect(Recommendation.count).to eq 1
    end

    it 'deletes user from recommendations where user is recipient' do
      FactoryGirl.create(:user_recommendation, users: [user])
      FactoryGirl.create(:user_recommendation, users: [user, second_user])
      FactoryGirl.create(:group_recommendation, group: group, users: group.users)
      expect(Recommendation.count).to eq 3
      expect { user.destroy! }.not_to raise_error
      expect(Recommendation.count).to eq 2
    end

    it 'deletes recommendation if user was last recipient' do
      FactoryGirl.create(:user_recommendation, users: [user])
      FactoryGirl.create(:user_recommendation, users: [user])
      FactoryGirl.create(:group_recommendation, group: group, users: group.users)
      expect(Recommendation.count).to eq 3
      expect { user.destroy! }.not_to raise_error
      expect(Recommendation.count).to eq 1
    end
  end

  describe 'factories' do
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
      expect(FactoryGirl.build_stubbed(:user, primary_email: '')).not_to be_valid
    end

    it 'uses the provided primary email for created users' do
      primary_email = 'test@example.com'
      user = FactoryGirl.create(:user, primary_email: 'test@example.com')
      user.primary_email = primary_email
    end

    it 'uses the provided primary email even for stubbed users' do
      primary_email = 'test@example.com'
      user = FactoryGirl.build_stubbed(:user, primary_email: 'test@example.com')
      user.primary_email = primary_email
    end

    it 'allows to users to be created without a primary email' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      expect(user1).to be_valid
      expect(user2).to be_valid
      expect(user1.primary_email).not_to eql user2.primary_email
    end

    it 'creates a user with an identity' do
      user = FactoryGirl.create(:OmniAuthUser)
      expect(user).to be_valid
      expect(user.password_autogenerated).to eql true
      expect(UserEmail.find_by(user: user, is_primary: true).autogenerated?).to eql true
      expect(UserIdentity.find_by(user: user, omniauth_provider: 'openProvider')).to be_valid
    end
  end

  describe 'common_groups_with_user(other_user)' do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    it 'displays only common groups' do
      FactoryGirl.create(:group, users: [user])
      group = FactoryGirl.create(:group, users: [user, other_user])
      expect(user.common_groups_with_user(other_user)).to match([group])
    end

    it 'displays all groups if they are equal' do
      group1 = FactoryGirl.create(:group, users: [user, other_user])
      group2 = FactoryGirl.create(:group, users: [user, other_user])
      expect(user.common_groups_with_user(other_user)).to match_array([group1, group2])
    end

    it 'is empty if there are no common groups' do
      FactoryGirl.create(:group, users: [user])
      FactoryGirl.create(:group, users: [other_user])
      expect(user.common_groups_with_user(other_user)).to match([])
    end
  end

  describe 'primary_email' do
    it 'returns only the primary email address which belongs to the user' do
      user = FactoryGirl.create(:user, primary_email: 'test@example.com')
      FactoryGirl.create(:user_email, user: user, address: 'second@example.com', is_primary: false)
      expect(user.primary_email).to eql 'test@example.com'
      expect(user.emails.pluck(:address)).to match_array ['test@example.com', 'second@example.com']
    end

    it 'returns nil if no address could be found (what should never happen)' do
      user = FactoryGirl.create(:user, primary_email: 'test@example.com')
      UserEmail.destroy_all(user: user)
      expect(user.primary_email).to eql nil
    end
  end

  describe 'primary_email=' do
    self.use_transactional_fixtures = false

    before(:all) do
      DatabaseCleaner.strategy = :truncation
    end

    after(:all) do
      DatabaseCleaner.strategy = :transaction
    end

    it 'creates a new UserEmail for the given primary email address' do
      user_data = FactoryGirl.build_stubbed(:user)
      user = described_class.new
      user.first_name = user_data.first_name
      user.last_name = user_data.last_name
      user.primary_email = user_data.primary_email
      user.password = user_data.password
      expect { user.save! }.not_to raise_error
      expect(user.instance_variable_get(:@primary_email_object)).to eql UserEmail.find_by_user_id(user)
      expect(user.primary_email).to eql user_data.primary_email
    end

    it 'updates the primary email without creating a new UserEmail object' do
      user = FactoryGirl.build(:user, primary_email: 'test@example.com')
      user.save!
      expect do
        user.primary_email = 'abc@example.com'
        user.save!
      end.not_to change { UserEmail.count }
      expect(UserEmail.find_by_address('test@example.com')).to be_nil
      expect(UserEmail.find_by_address('abc@example.com').user).to eql user
    end

    it 'updates a user' do
      user = FactoryGirl.build(:user, primary_email: 'test@example.com')
      user.save
      expect do
        user.update!(primary_email: 'new@email.com')
        user.save!
      end.not_to raise_error
      expect(described_class.find_by_primary_email('new@email.com')).to eql user
      expect(user.persisted?).to be true
    end
  end

  describe 'find_by_primary_email' do
    it 'returns the requested user' do
      user = FactoryGirl.create(:user, primary_email: 'test@example.com')
      expect(described_class.find_by_primary_email('test@example.com')).to eql user
    end

    it 'returns nil if no user could be found' do
      FactoryGirl.create(:user, primary_email: 'test@example.com')
      expect(described_class.find_by_primary_email('abc@example.com')).to be_nil
    end

    it 'does not find other addresses which are not primary' do
      user = FactoryGirl.create(:user, primary_email: 'test@example.com')
      secondary_email = FactoryGirl.create(:user_email, user: user, address: 'abc@example.com', is_primary: false)
      expect(described_class.find_by_primary_email('abc@example.com')).to be_nil
      expect(UserEmail.find_by_address('abc@example.com')).to eql secondary_email
    end
  end

  describe 'connected_users_ids' do
    let(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:third_user) { FactoryGirl.create(:user) }
    let(:userlist) do
      result = FactoryGirl.create_list(:user, 5)
      result += [user]
      result += [third_user]
      result
    end
    let!(:group1) { FactoryGirl.create(:group, users: userlist) }
    let!(:group2) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }

    it 'returns the ids of all users of all my groups' do
      result = user.connected_users_ids
      expect(result).to include second_user.id
      userlist.each do |a|
        expect(result).to include(a.id) unless a.id == user.id
      end
    end

    it 'does not return my own id' do
      expect(user.connected_users_ids).not_to include user.id
    end

    it 'returns only unique ids' do
      result = user.connected_users_ids
      expect(result.detect {|e| result.count(e) > 1 }).to be_nil
    end
  end

  describe 'connected_users' do
    let(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:third_user) { FactoryGirl.create(:user) }
    let(:userlist) do
      result = FactoryGirl.create_list(:user, 5)
      result += [user]
      result += [third_user]
      result
    end
    let!(:group1) { FactoryGirl.create(:group, users: userlist) }
    let!(:group2) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }

    it 'returns all users of all my groups' do
      result = user.connected_users
      expect(result).to include second_user
      userlist.each do |a|
        expect(result).to include(a) unless a == user
      end
    end

    it 'does not return the current user' do
      expect(user.connected_users).not_to include user
    end

    it 'returns only unique users' do
      result = user.connected_users
      expect(result.detect {|e| result.count(e) > 1 }).to be_nil
    end
  end

  describe 'connected_groups_ids' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:group1) { FactoryGirl.create(:group, users: [user]) }
    let!(:group2) { FactoryGirl.create(:group, users: [user]) }

    it 'returns all group_ids' do
      result = user.connected_groups_ids
      expect(result).to include group1.id
      expect(result).to include group2.id
    end

    it 'return only unique values' do
      result = user.connected_groups_ids
      expect(result.detect {|e| result.count(e) > 1 }).to be_nil
    end
  end

  describe 'save_primary_email' do
    it 'returns without saving if @primary_email_object is undefined' do
      user = FactoryGirl.create(:user, primary_email: 'test@example.com')
      user.instance_variable_set(:@primary_email_object, nil)
      expect(user.send(:save_primary_email)).to be_nil
    end

    it 'sets the user if necessary' do
      user = FactoryGirl.build(:user, primary_email: 'test@example.com')
      user_email = FactoryGirl.build(:user_email, user: nil, address: 'test@example.com')
      user.instance_variable_set(:@primary_email_object, user_email)
      expect(user.send(:save_primary_email)).to be true
      expect(described_class.find_by_primary_email('test@example.com')).to eql user
    end

    it 'raises an Exception if the @primary_email_object is valid for another user' do
      user = FactoryGirl.build(:user, primary_email: 'test@example.com')
      another_user = FactoryGirl.create(:user, primary_email: 'test2@example.com')
      user_email = FactoryGirl.build(:user_email, user: another_user, address: 'test@example.com')
      user.instance_variable_set(:@primary_email_object, user_email)
      expect { user.send(:save_primary_email) }.to raise_error NoMethodError
      expect(described_class.find_by_primary_email('test2@example.com')).to eql another_user
      expect(described_class.find_by_primary_email('test@example.com')).to be_nil
    end
  end

  describe 'self.find_first_by_auth_conditions' do
    it 'returns the saved user' do
      user = FactoryGirl.create(:user, primary_email: 'test@example.com')
      expect(described_class.find_first_by_auth_conditions(primary_email: user.primary_email)).to eql user
    end

    it 'returns nil if a user could not be found' do
      FactoryGirl.create(:user, primary_email: 'test@example.com')
      expect(described_class.find_first_by_auth_conditions(primary_email: 'invalid')).to be_nil
    end

    it 'calls the super method if no primary_email is submitted' do
      warden_conditions = {unknown: 'attribute'}
      expect_any_instance_of(Devise::Models::Authenticatable::ClassMethods).to receive(:find_first_by_auth_conditions).with(warden_conditions)
      described_class.find_first_by_auth_conditions(warden_conditions)
    end
  end

  describe 'self.find_for_omniauth' do
    self.use_transactional_fixtures = false

    before(:all) do
      DatabaseCleaner.strategy = :truncation
    end

    after(:all) do
      DatabaseCleaner.strategy = :transaction
    end

    it 'creates a new user account with the given authentication infos including an email address' do
      identity = FactoryGirl.build_stubbed(:user_identity)
      authentication_info = OmniAuth::AuthHash.new(
        provider: identity.omniauth_provider,
        uid: identity.provider_user_id,
        info: {
          first_name: 'Max',
          last_name: 'Mustermann',
          image: nil,
          email: 'max@example.com',
          verified: true
        },
        extra: {
          raw_info: {
            middle_name: nil
          }
        }
      )
      expect { described_class.find_for_omniauth(authentication_info) }.to change { described_class.count }.by(1)
      user = described_class.find_by_primary_email(authentication_info.info.email)
      expect(user.first_name).to eql authentication_info.info.first_name
      expect(user.last_name).to eql authentication_info.info.last_name
      expect(user.primary_email).to eql authentication_info.info.email
      expect(user.password_autogenerated).to eql true
      expect(UserEmail.find_by_address(user.primary_email).is_verified).to eql true
      expect(UserIdentity.find_by(omniauth_provider: authentication_info.provider, provider_user_id: authentication_info.uid).user).to eql user
    end

    it 'creates a new user account with the given authentication infos even when no email address is provided' do
      identity = FactoryGirl.build_stubbed(:user_identity)
      authentication_info = OmniAuth::AuthHash.new(
        provider: identity.omniauth_provider,
        uid: identity.provider_user_id,
        info: {
          first_name: 'Max',
          last_name: 'Mustermann',
          image: 'https://example.com/user/image',
          email: '',
          verified: false
        },
        extra: {
          raw_info: {
            middle_name: 'Maximus'
          }
        }
      )
      expect { described_class.find_for_omniauth(authentication_info) }.to change { described_class.count }.by(1)
      user = UserIdentity.find_by(omniauth_provider: authentication_info.provider, provider_user_id: authentication_info.uid).user
      expect(user.first_name).to eql "#{authentication_info.info.first_name} #{authentication_info.extra.raw_info.middle_name}"
      expect(user.last_name).to eql authentication_info.info.last_name
      expect(user.password_autogenerated).to eql true
      primary_email_object = UserEmail.find_by_address(user.primary_email)
      expect(primary_email_object.autogenerated?).to eql true
      expect(primary_email_object.is_verified).to eql false
    end

    it 'returns the existing user if already saved and does not create an empty new email address' do
      user = FactoryGirl.create(:OmniAuthUser)
      identity = UserIdentity.find_by(user: user)
      authentication_info = OmniAuth::AuthHash.new(
        provider: identity.omniauth_provider,
        uid: identity.provider_user_id,
        info: {
          email: '',
          verified: false
        }
      )
      email_address_count = UserEmail.count(user: user)
      expect { described_class.find_for_omniauth(authentication_info) }.not_to change { described_class.count }
      expect(email_address_count).to eql UserEmail.count(user: user)
    end

    it 'returns the existing user if already saved and does not create the email address again' do
      user = FactoryGirl.create(:OmniAuthUser)
      identity = UserIdentity.find_by(user: user)
      authentication_info = OmniAuth::AuthHash.new(
        provider: identity.omniauth_provider,
        uid: identity.provider_user_id,
        info: {
          email: user.primary_email,
          verified: false
        }
      )
      email_address_count = UserEmail.count(user: user)
      expect { described_class.find_for_omniauth(authentication_info) }.not_to change { described_class.count }
      expect(email_address_count).to eql UserEmail.count(user: user)
    end

    it 'returns the existing user if already saved and adds the email address if not saved yet' do
      user = FactoryGirl.create(:OmniAuthUser)
      identity = UserIdentity.find_by(user: user)
      authentication_info = OmniAuth::AuthHash.new(
        provider: identity.omniauth_provider,
        uid: identity.provider_user_id,
        info: {
          email: 'other_email@example.com',
          verified: false
        }
      )
      expect(user.primary_email).not_to eql authentication_info.info.email
      email_address_count = UserEmail.count(user: user)
      expect { described_class.find_for_omniauth(authentication_info) }.not_to change { described_class.count }
      expect(email_address_count + 1).to eql UserEmail.count(user: user)
    end

    it 'associates the user identity with the user if signed in' do
      user = FactoryGirl.create(:OmniAuthUser)
      UserIdentity.find_by(user: user)
      authentication_info = OmniAuth::AuthHash.new(
        provider: 'second_provider',
        uid: 'second_user_id',
        info: {
          email: 'other_email@example.com',
          verified: false
        }
      )
      identity = UserIdentity.count(user: user)
      expect { described_class.find_for_omniauth(authentication_info, user) }.not_to change { described_class.count }
      expect(identity + 1).to eql UserIdentity.count(user: user)
    end

    it 'does not create the same user identity again if the user is signed in' do
      user = FactoryGirl.create(:OmniAuthUser)
      identity = UserIdentity.find_by(user: user)
      authentication_info = OmniAuth::AuthHash.new(
        provider: identity.omniauth_provider,
        uid: identity.provider_user_id,
        info: {
          email: 'other_email@example.com',
          verified: false
        }
      )
      identity = UserIdentity.count(user: user)
      expect { described_class.find_for_omniauth(authentication_info, user) }.not_to change { described_class.count }
      expect(identity).to eql UserIdentity.count(user: user)
    end
  end

  describe 'first_name_autogenerated?' do
    let!(:user) { FactoryGirl.create(:user) }

    it 'response false if no user identity could be found' do
      expect(user.first_name_autogenerated?).to eql false
    end

    it 'response false if user identities are present but first_name is not autogenerated' do
      UserIdentity.create!(user: user, omniauth_provider: 'provider1', provider_user_id: '123')
      UserIdentity.create!(user: user, omniauth_provider: 'provider2', provider_user_id: '456')
      expect(user.first_name_autogenerated?).to eql false
    end

    it 'response true if the first_name is autogenerated with the user identity' do
      identity = UserIdentity.create!(user: user, omniauth_provider: 'provider1', provider_user_id: '123')
      user.first_name = "autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com"
      user.save!
      expect(user.first_name_autogenerated?).to eql true
    end
  end

  describe 'last_name_autogenerated?' do
    let!(:user) { FactoryGirl.create(:OmniAuthUser) }

    it 'response false if no user identity could be found' do
      expect(user.last_name_autogenerated?).to eql false
    end

    it 'response false if user identities are present but last_name is not autogenerated' do
      UserIdentity.create!(user: user, omniauth_provider: 'provider1', provider_user_id: '123')
      UserIdentity.create!(user: user, omniauth_provider: 'provider2', provider_user_id: '456')
      expect(user.last_name_autogenerated?).to eql false
    end

    it 'response true if the last_name is autogenerated with the user identity' do
      identity = UserIdentity.create!(user: user, omniauth_provider: 'provider1', provider_user_id: '123')
      user.last_name = "autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com"
      user.save!
      expect(user.last_name_autogenerated?).to eql true
    end
  end

  describe 'groups_sorted_by_admin_state_and_name' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:group1) { FactoryGirl.create(:group, users: [user], name: 'C') }
    let!(:group2) { FactoryGirl.create(:group, users: [user], name: 'B') }
    let!(:group3) { FactoryGirl.create(:group, users: [user], name: 'D') }
    let!(:group4) { FactoryGirl.create(:group, users: [user], name: 'A') }

    before(:each) do
      UserGroup.set_is_admin(group1.id, user.id, true)
      UserGroup.set_is_admin(group2.id, user.id, true)
    end

    it 'returns all groups' do
      expect(user.groups_sorted_by_admin_state_and_name).to match_array([group1, group2, group3, group4])
    end

    it 'returns the groups where the user is admin sorted by name and following by a sorted list of groups where the user is no admin' do
      expect(user.groups_sorted_by_admin_state_and_name).to match([group2, group1, group4, group3])
    end
  end

  describe 'self.process_uri' do
    before(:each) do
      allow(described_class).to receive(:process_uri).and_call_original
    end

    it 'returns if no uri is passed' do
      expect { described_class.process_uri(nil) }.not_to raise_error
      expect(described_class.process_uri(nil)).to be_nil
    end

    it 'changes the URL scheme to https and returns' do
      expect(described_class.process_uri('http://www.example.com/avatar.png')).to eql 'https://www.example.com/avatar.png'
    end
  end

  describe 'setting(key, create_new)' do
    let(:user) { FactoryGirl.create :user }
    let(:user_setting) { FactoryGirl.create :user_setting, user: user }

    it 'returns UserSetting object' do
      expect(user.setting(user_setting.name)).to eq user_setting
    end

    context 'UserSetting object does not exist' do
      it 'creates new UserSetting' do
        expect { user.setting(:newsetting, true) }.to change { UserSetting.count }.by(1)
      end
    end
  end
end
