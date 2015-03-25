require 'rails_helper'
require 'database_cleaner'

RSpec.describe GroupsController, :type => :feature do

  self.use_transactional_fixtures = false

  before(:each) do
    @user = FactoryGirl.create(:user)
    @second_user = FactoryGirl.create(:user)
    @third_user = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group, users: [@user, @second_user, @third_user])
    UserGroup.set_is_admin(@group.id, @user.id, true)

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
  end
end
