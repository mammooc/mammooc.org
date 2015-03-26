require 'rails_helper'
require 'database_cleaner'

RSpec.describe GroupsController, :type => :feature do

  self.use_transactional_fixtures = false

  before(:each) do
    @user = FactoryGirl.create(:user)
    @second_user = FactoryGirl.create(:user)
    @third_user = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group, users: [@user, @second_user, @third_user])
    @second_group = FactoryGirl.create(:group, users: [@user])
    UserGroup.set_is_admin(@group.id, @user.id, true)
    UserGroup.set_is_admin(@second_group.id, @user.id, true)

    visit new_user_session_path
    fill_in 'login_email', with: @user.email
    fill_in 'login_password', with: @user.password
    click_button 'submit_sign_in'

    ActionMailer::Base.deliveries.clear
  end

  after(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  describe 'invite users to an existing group' do

    it 'should invite a user to a group', js: true do
      visit "/groups/#{@group.id}/members"
      click_on 'btn-invite-members'
      fill_in 'text_area_invite_members', with: 'max@test.com'
      click_button 'Submit'
      wait_for_ajax
      expect(current_path).to eq("/groups/#{@group.id}/members")
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(GroupInvitation.count).to eq 1
    end
  end

  describe 'change administrator status' do

    it 'should add an admin to an existing group', js:true do
      visit "/groups/#{@group.id}/members"
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.add_admin')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{@group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 2
      expect(find("#list_member_element_user_#{@third_user.id}")).to have_selector 'div.col-md-4.list-members.admins'
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      expect(page).to have_content I18n.t('groups.all_members.demote_admin')
    end

    it 'should demote an admin to an existing group', js:true do
      UserGroup.set_is_admin(@group.id, @third_user.id, true)
      visit "/groups/#{@group.id}/members"
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.demote_admin')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{@group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 1
      expect(find("#list_member_element_user_#{@third_user.id}")).to have_selector 'div.col-md-4.list-members'
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      expect(page).to have_content I18n.t('groups.all_members.add_admin')
    end

    it 'should add an admin and demote and add him again', js:true do
      visit "/groups/#{@group.id}/members"
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.add_admin')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{@group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 2
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.demote_admin')
      wait_for_ajax
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 1
      expect(find("#list_member_element_user_#{@third_user.id}")).to have_selector 'div.col-md-4.list-members'
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.add_admin')
      wait_for_ajax
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 2
      expect(find("#list_member_element_user_#{@third_user.id}")).to have_selector 'div.col-md-4.list-members.admins'
    end

    it 'should not demote last admin', js:true do
      visit "/groups/#{@group.id}/members"
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.demote_admin')
      wait_for_ajax
      expect(page).to have_content I18n.t('groups.all_members.demote_last_admin_notice')
      click_on I18n.t('groups.all_members.demote_last_admin_button')
      expect(current_path).to eq("/groups/#{@group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq(UserGroup.where(group_id: @group.id, is_admin: true).count)
    end

    it 'should not demote last admin (additional last member)', js:true do
      visit "/groups/#{@second_group.id}/members"
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.demote_admin')
      wait_for_ajax
      expect(page).to have_content I18n.t('groups.all_members.demote_last_admin_notice')
      click_on I18n.t('groups.all_members.demote_last_admin_button')
      expect(current_path).to eq("/groups/#{@second_group.id}/members")
      current_admins_of_group = UserGroup.where(group_id: @second_group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq(UserGroup.where(group_id: @second_group.id, is_admin: true).count)
    end


  end

  describe 'remove member' do

    it 'should remove the chosen member', js:true do
      visit "/groups/#{@group.id}/members"
      number_of_members = @group.users.count
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.remove_member')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_remove_member')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{@group.id}/members")
      expect(@group.users.count).to eq number_of_members-1
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq (UserGroup.where(group_id: @group.id, is_admin: true)).count
      expect { find("#list_member_element_user_#{@third_user.id}") }.to raise_error
      expect(UserGroup.where(group_id: @group.id, user_id: @third_user.id).empty?).to be_truthy
    end

    it 'should remove the chosen admin', js:true do
      UserGroup.set_is_admin(@group.id, @third_user.id, true)
      visit "/groups/#{@group.id}/members"
      number_of_members = @group.users.count
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.remove_member')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_remove_member')
      wait_for_ajax
      expect(current_path).to eq("/groups/#{@group.id}/members")
      expect(@group.users.count).to eq number_of_members-1
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq (UserGroup.where(group_id: @group.id, is_admin: true)).count
      expect { find("#list_member_element_user_#{@third_user.id}") }.to raise_error
      expect(UserGroup.where(group_id: @group.id, user_id: @third_user.id).empty?).to be_truthy
    end

    it 'should remove more than one chosen member', js:true do
      visit "/groups/#{@group.id}/members"
      number_of_members = @group.users.count

      # delete one member
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@third_user.id}").click_on I18n.t('groups.all_members.remove_member')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_remove_member')
      wait_for_ajax

      # delete another member
      find("#list_member_element_user_#{@second_user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@second_user.id}").click_on I18n.t('groups.all_members.remove_member')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_remove_member')
      wait_for_ajax

      expect(current_path).to eq("/groups/#{@group.id}/members")
      expect(@group.users.count).to eq number_of_members-2
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq (UserGroup.where(group_id: @group.id, is_admin: true)).count

      expect { find("#list_member_element_user_#{@second_user.id}") }.to raise_error
      expect(UserGroup.where(group_id: @group.id, user_id: @second_user.id).empty?).to be_truthy
      expect { find("#list_member_element_user_#{@third_user.id}") }.to raise_error
      expect(UserGroup.where(group_id: @group.id, user_id: @third_user.id).empty?).to be_truthy

    end

    it 'should delete the group if the last member wants to leave (after confirmation)', js:true do
      visit "/groups/#{@second_group.id}/members"
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.leave_group')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_delete_group')
      wait_for_ajax
      expect(current_path).to eq groups_path
      expect{ Group.find(@second_group.id) }.to raise_error
    end

    it 'should delete the group if the last admin wants to leave (after confirmation)', js:true do
      visit "/groups/#{@group.id}/members"
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.leave_group')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_delete_group')
      wait_for_ajax
      expect(current_path).to eq groups_path
      expect{ Group.find(@group.id) }.to raise_error
    end

    it 'should make all members to admins if the last admin wants to leave (after confirmation)', js:true do
      visit "/groups/#{@group.id}/members"
      number_of_members = @group.users.count
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.options')
      find("#list_member_element_user_#{@user.id}").click_on I18n.t('groups.all_members.leave_group')
      wait_for_ajax
      click_on I18n.t('groups.remove_member.confirm_leave_group')
      wait_for_ajax
      expect(current_path).to eq groups_path
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq(@group.users.count)
      expect(@group.users.count).to eq number_of_members-1
      expect { UserGroup.where(group_id: @group.id, user_id: user.id) }.to raise_error
    end
  end
end
