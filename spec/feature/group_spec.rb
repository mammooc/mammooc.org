require 'rails_helper'

RSpec.describe GroupsController, :type => :feature do

  self.use_transactional_fixtures = false
  describe 'invite users to an existing group' do

    before(:all) do
      DatabaseCleaner.strategy = :truncation
    end

    after(:all) do
      DatabaseCleaner.strategy = :transaction
    end

    before(:each) do
      @user = FactoryGirl.create(:user)
      @group = FactoryGirl.create(:group, users: [@user])
      visit new_user_session_path
      fill_in 'login_email', with: @user.email
      fill_in 'login_password', with: @user.password
      click_button 'submit_sign_in'
      ActionMailer::Base.deliveries.clear
    end


    it 'should invite a user to a group', js: true do
      visit group_path(@group.id)
      expect(page).to have_content('Member(s)')
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
end