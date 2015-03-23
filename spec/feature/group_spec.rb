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
      visit group_path(@group.id)
      click_on 'add_members_symbol'
      fill_in 'text_area_invite_members', with: 'max@test.com'
      click_button 'Submit'
      # Wait until modal has disappeared
      wait_for_ajax
      expect(current_path).to eq(group_path(@group.id))
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(GroupInvitation.count).to eq 1
    end
  end

  describe 'add administrator to an existing group' do

    it 'should add an admin to an existing group', js:true do
      visit group_path(@group.id)
      click_on 'add_administrators_symbol'
      check 'checkbox_add_as_admin_0'
      click_button 'Submit'
      # Wait until modal has disappeared
      wait_for_ajax
      expect(current_path).to eq(group_path(@group.id))
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 2
    end

    it 'should add more than one admin to an existing group', js:true do
      visit group_path(@group.id)
      click_on 'add_administrators_symbol'
      check 'checkbox_add_as_admin_0'
      check 'checkbox_add_as_admin_1'
      click_button 'Submit'
      # Wait until modal has disappeared
      wait_for_ajax
      expect(current_path).to eq(group_path(@group.id))
      current_admins_of_group = UserGroup.where(group_id: @group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 3
    end

  end

  describe 'show all group members' do
    it 'should show all members of the group (including admins)' do
      create_users = FactoryGirl.create_list(:user, 10)
      @group.users.push(create_users)
      visit group_path(@group)
      click_on I18n.t('groups.show_all')
      expect(page).to have_content I18n.t('groups.modal.title')
      @group.users.each do |user|
        expect(page).to have_content user.first_name
      end
    end
  end

  describe 'show all group administrators' do
    it 'should show all members of the group (including admins)' do
      create_users = FactoryGirl.create_list(:user, 10)
      @group.users.push(create_users)
      create_users.each do |user|
        UserGroup.set_is_admin(@group.id, user.id, true)
      end
      visit group_path(@group)
      click_on I18n.t('groups.show_all')
      expect(page).to have_content I18n.t('groups.all_admins')
      create_users.each do |user|
        expect(page).to have_content user.first_name
      end
    end
  end

end