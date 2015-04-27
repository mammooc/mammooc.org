require 'rails_helper'

RSpec.describe GroupsController, type: :feature do

  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }
  let(:second_user) { FactoryGirl.create(:user) }
  let(:third_user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }
  let(:second_group) { FactoryGirl.create(:group, users: [user]) }

  before(:each) do
    UserGroup.set_is_admin(group.id, user.id, true)
    UserGroup.set_is_admin(second_group.id, user.id, true)

    visit new_user_session_path
    fill_in 'login_email', with: user.email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'

    ActionMailer::Base.deliveries.clear
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end


  describe 'invite users to an existing group' do

    it 'should invite a user to a group', js: true do
      visit "/groups/#{group.id}/members"
      click_on 'btn-invite-members'
      fill_in 'text_area_invite_members', with: 'max@test.com'
      click_button I18n.t('global.submit')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{group.id}/members")
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(GroupInvitation.count).to eq 1
    end

    it 'should not invite a user to a group if the email address is misspelled', js: true do
      visit "/groups/#{group.id}/members"
      click_on 'btn-invite-members'
      fill_in 'text_area_invite_members', with: 'max@testcom'
      click_button I18n.t('global.submit')
      wait_for_ajax
      expect(page).to have_content I18n.t('groups.add_members.error')
      expect(find('#text_area_invite_members').value).to have_content('max@testcom')
      expect(current_path).to eq("/groups/#{group.id}/members")
      expect(ActionMailer::Base.deliveries.count).to eq 0
      expect(GroupInvitation.count).to eq 0
    end

    it 'should invite users with valid address and reject these with invalid address', js:true do
      visit "/groups/#{group.id}/members"
      click_on 'btn-invite-members'
      fill_in 'text_area_invite_members', with: 'max@test.com, max@testcom'
      click_button I18n.t('global.submit')
      wait_for_ajax
      expect(page).to have_content I18n.t('groups.add_members.error')
      expect(find('#text_area_invite_members').value).to have_content('max@testcom')
      expect(current_path).to eq("/groups/#{group.id}/members")
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(GroupInvitation.count).to eq 1
    end

    it 'should empty the textbox after successfull invite and remove the error', js:true do
      visit "/groups/#{group.id}/members"
      click_on 'btn-invite-members'
      fill_in 'text_area_invite_members', with: 'max@test.com, max@testcom'
      click_button I18n.t('global.submit')
      wait_for_ajax
      expect(page).to have_content I18n.t('groups.add_members.error')
      expect(find('#text_area_invite_members').value).to have_content('max@testcom')
      fill_in 'text_area_invite_members', with: 'maxi@test.com'
      click_button I18n.t('global.submit')
      wait_for_ajax
      click_on 'btn-invite-members'
      wait_for_ajax
      expect(page).not_to have_content('@test')
      expect(page).not_to have_content I18n.t('groups.add_members.error')
      expect(current_path).to eq("/groups/#{group.id}/members")
      expect(ActionMailer::Base.deliveries.count).to eq 2
      expect(GroupInvitation.count).to eq 2
    end
  end

  describe 'change administrator status' do

    it 'should add an admin to an existing group', js:true do
      visit "/groups/#{group.id}/members"
      find("#list_member_element_user_#{third_user.id}").click_on I18n.t('groups.all_members.add_admin')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 2
      expect(find("#list_member_element_user_#{third_user.id}")).to have_selector '.options'
      expect(page).to have_content I18n.t('groups.all_members.demote_admin')
    end

    it 'should demote an admin to an existing group', js:true do
      UserGroup.set_is_admin(group.id, third_user.id, true)
      visit "/groups/#{group.id}/members"
      find("#list_member_element_user_#{third_user.id}").click_on I18n.t('groups.all_members.demote_admin')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 1
      expect(find("#list_member_element_user_#{third_user.id}")).to have_selector '.options'
      expect(page).to have_content I18n.t('groups.all_members.add_admin')
    end

    it 'should add an admin and demote and add him again', js:true do
      visit "/groups/#{group.id}/members"
      find("#list_member_element_user_#{third_user.id}").click_on I18n.t('groups.all_members.add_admin')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 2
      find("#list_member_element_user_#{third_user.id}").click_on I18n.t('groups.all_members.demote_admin')
      wait_for_ajax
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 1
      expect(find("#list_member_element_user_#{third_user.id}")).to have_selector '.options'
      find("#list_member_element_user_#{third_user.id}").click_on I18n.t('groups.all_members.add_admin')
      wait_for_ajax
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 2
      expect(find("#list_member_element_user_#{third_user.id}")).to have_selector '.options'
    end

    it 'should not demote last admin', js:true do
      visit "/groups/#{group.id}/members"
      find("#list_member_element_user_#{user.id}").click_on I18n.t('groups.all_members.demote_admin')
      wait_for_ajax
      expect(page).to have_content I18n.t('groups.all_members.demote_last_admin_notice')
      click_on I18n.t('groups.all_members.demote_last_admin_button')
      expect(current_path).to eq("/groups/#{group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq(UserGroup.where(group_id: group.id, is_admin: true).count)
    end

    it 'should not demote last admin (additional last member)', js:true do
      visit "/groups/#{second_group.id}/members"
      find("#list_member_element_user_#{user.id}").click_on I18n.t('groups.all_members.demote_admin')
      wait_for_ajax
      expect(page).to have_content I18n.t('groups.all_members.demote_last_admin_notice')
      click_on I18n.t('groups.all_members.demote_last_admin_button')
      expect(current_path).to eq("/groups/#{second_group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: second_group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq(UserGroup.where(group_id: second_group.id, is_admin: true).count)
    end


  end

  describe 'remove member' do

    it 'should remove the chosen member', js:true do
      visit "/groups/#{group.id}/members"
      number_of_members = group.users.count
      find("#list_member_element_user_#{third_user.id}").click_on I18n.t('groups.all_members.remove_member')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_remove_member')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{group.id}/members")
      expect(group.users.count).to eq number_of_members-1
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq (UserGroup.where(group_id: group.id, is_admin: true)).count
      expect { find("#list_member_element_user_#{third_user.id}") }.to raise_error
      expect(UserGroup.where(group_id: group.id, user_id: third_user.id).empty?).to be_truthy
    end

    it 'should remove the chosen admin', js:true do
      UserGroup.set_is_admin(group.id, third_user.id, true)
      visit "/groups/#{group.id}/members"
      number_of_members = group.users.count
      find("#list_member_element_user_#{third_user.id}").click_on I18n.t('groups.all_members.remove_member')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_remove_member')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{group.id}/members")
      expect(group.users.count).to eq number_of_members-1
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq (UserGroup.where(group_id: group.id, is_admin: true)).count
      expect { find("#list_member_element_user_#{third_user.id}") }.to raise_error
      expect(UserGroup.where(group_id: group.id, user_id: third_user.id).empty?).to be_truthy
    end

    it 'should remove more than one chosen member', js:true do
      visit "/groups/#{group.id}/members"
      number_of_members = group.users.count

      # delete one member
      find("#list_member_element_user_#{third_user.id}").click_on I18n.t('groups.all_members.remove_member')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_remove_member')
      wait_for_ajax

      # delete another member
      find("#list_member_element_user_#{second_user.id}").click_on I18n.t('groups.all_members.remove_member')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_remove_member')
      wait_for_ajax

      expect(current_path).to eq("/groups/#{group.id}/members")
      expect(group.users.count).to eq number_of_members-2
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq (UserGroup.where(group_id: group.id, is_admin: true)).count

      expect { find("#list_member_element_user_#{second_user.id}") }.to raise_error
      expect(UserGroup.where(group_id: group.id, user_id: second_user.id).empty?).to be_truthy
      expect { find("#list_member_element_user_#{third_user.id}") }.to raise_error
      expect(UserGroup.where(group_id: group.id, user_id: third_user.id).empty?).to be_truthy

    end

    it 'should delete the group if the last member wants to leave (after confirmation)', js:true do
      visit "/groups/#{second_group.id}/members"
      find("#list_member_element_user_#{user.id}").click_on I18n.t('groups.all_members.leave_group')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_delete_group')
      wait_for_ajax
      expect(current_path).to eq groups_path
      expect{ Group.find(second_group.id) }.to raise_error
    end

    it 'should delete the group if the last admin wants to leave (after confirmation)', js:true do
      visit "/groups/#{group.id}/members"
      find("#list_member_element_user_#{user.id}").click_on I18n.t('groups.all_members.leave_group')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_delete_group')
      wait_for_ajax
      expect(current_path).to eq groups_path
      expect{ Group.find(group.id) }.to raise_error
    end

    it 'should make all members to admins if the last admin wants to leave (after confirmation)', js:true do
      visit "/groups/#{group.id}/members"
      number_of_members = group.users.count
      find("#list_member_element_user_#{user.id}").click_on I18n.t('groups.all_members.leave_group')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_leave_group')
      wait_for_ajax
      expect(current_path).to eq groups_path
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq(group.users.count)
      expect(group.users.count).to eq number_of_members-1
      expect(UserGroup.where(group_id: group.id, user_id: user.id).empty?).to be_truthy
    end
  end

  describe 'update statistics' do
    it 'should start user workers', js: true do
      expect(OpenHPIUserWorker).to receive(:perform_async).with(group.users.pluck(:id))
      expect(OpenSAPUserWorker).to receive(:perform_async).with(group.users.pluck(:id))

      visit "/groups/#{group.id}/statistics"
      click_button 'sync-group-course-button'
      wait_for_ajax
    end
  end

end
