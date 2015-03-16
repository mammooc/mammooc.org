require 'rails_helper'

RSpec.describe "Group", :type => :feature do

  describe 'invite users to an existing group' do


    let(:user) { FactoryGirl.create(:user) }
    let!(:group) { FactoryGirl.create(:group, users: [user]) }

    before(:each) do
      visit new_user_session_path
      fill_in 'login_email', with: user.email
      fill_in 'login_password', with: user.password
      click_button 'submit_sign_in'
      ActionMailer::Base.deliveries.clear
    end



    it 'should invite a user to a group' do
      visit group_path(group.id)
      expect(page).to have_content('Member(s)')
      click_on 'add_members_symbol'
      fill_in 'text_area_invite_members', with: 'max@test.com'
      click_button 'Update Group'
      expect(current_path).to eq(group_path(group.id))
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(GroupInvitation.count).to eq 1
    end

  end
end