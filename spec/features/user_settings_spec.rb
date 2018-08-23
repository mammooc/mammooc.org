# frozen_string_literal: true

require 'rails_helper'
require 'support/feature_support'

RSpec.describe 'UserSettings', type: :feature do
  let(:user) { FactoryBot.create(:user) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  describe 'course enrollments' do
    let(:course1) { FactoryBot.create(:course) }
    let(:second_user) { FactoryBot.create(:user, courses: [course1]) }
    let(:third_user) { FactoryBot.create(:user) }
    let(:fourth_user) { FactoryBot.create(:user) }
    let(:fifth_user) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, users: [second_user, fourth_user]) }
    let!(:second_group) { FactoryBot.create(:group, users: [second_user, fifth_user]) }
    let!(:group_for_activities) { FactoryBot.create(:group, users: [second_user, user, third_user]) }
    let(:user_setting) { FactoryBot.create(:user_setting, name: :course_enrollments_visibility, user: second_user) }
    let!(:user_setting_entry) { FactoryBot.create(:user_setting_entry, setting: user_setting, key: 'users', value: [user.id]) }
    let(:user_setting4) { FactoryBot.create(:user_setting, name: :course_enrollments_visibility, user: second_user) }
    let!(:user_setting_entry4) { FactoryBot.create(:user_setting_entry, setting: user_setting4, key: 'groups', value: [group.id]) }

    context "with the user's profile" do
      let(:user_setting2) { FactoryBot.create(:user_setting, name: :profile_visibility, user: second_user) }
      let!(:user_setting_entry2) { FactoryBot.create(:user_setting_entry, setting: user_setting2, key: 'users', value: [user.id, third_user.id]) }
      let(:user_setting3) { FactoryBot.create(:user_setting, name: :profile_visibility, user: second_user) }
      let!(:user_setting_entry3) { FactoryBot.create(:user_setting_entry, setting: user_setting3, key: 'groups', value: [group.id, second_group.id]) }

      it 'are visible for user himself' do
        capybara_sign_in second_user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).to have_content I18n.t('users.own_profile.current_courses')
        expect(page).to have_content course1.name
      end

      it 'are visible for users who are whitelisted' do
        capybara_sign_in user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).to have_content I18n.t('users.profile.current_courses')
        expect(page).to have_content course1.name
      end

      it 'are not visible for users who are not whitelisted' do
        capybara_sign_in third_user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).not_to have_content I18n.t('users.profile.current_courses')
        expect(page).not_to have_content course1.name
      end

      it 'are visible to users who are in groups which are whitelisted' do
        capybara_sign_in fourth_user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).to have_content I18n.t('users.profile.current_courses')
        expect(page).to have_content course1.name
      end

      it 'are not visible to users who are in groups which are not whitelisted' do
        capybara_sign_in fifth_user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).not_to have_content I18n.t('users.profile.current_courses')
        expect(page).not_to have_content course1.name
      end
    end

    context 'with the newsfeed' do
      let!(:activity) { FactoryBot.create(:activity_course_enroll, owner: second_user, trackable: course1, user_ids: [user.id, third_user.id, fourth_user.id, fifth_user.id], group_ids: [group.id, second_group.id]) }

      it 'are visible for users who are whitelisted' do
        capybara_sign_in user
        visit dashboard_path
        expect(page).to have_content I18n.t('newsfeed.course.enroll')
        expect(page).to have_content course1.name
      end

      it 'are not visible for users who are not whitelisted' do
        capybara_sign_in third_user
        visit dashboard_path
        expect(page).not_to have_content I18n.t('newsfeed.course.enroll')
        expect(page).not_to have_content course1.name
      end

      it 'are visible to users who are in groups which are whitelisted' do
        capybara_sign_in fourth_user
        visit dashboard_path
        expect(page).to have_content I18n.t('newsfeed.course.enroll')
        expect(page).to have_content course1.name
      end

      it 'are not visible to users who are in groups which are not whitelisted' do
        capybara_sign_in fifth_user
        visit dashboard_path
        expect(page).not_to have_content I18n.t('newsfeed.course.enroll')
        expect(page).not_to have_content course1.name
      end

      it 'are visible for groups which are whitelisted' do
        capybara_sign_in fourth_user
        visit group_path(group)
        expect(page).to have_content I18n.t('newsfeed.course.enroll')
        expect(page).to have_content course1.name
      end

      it 'are not visible for groups which are not whitelisted' do
        capybara_sign_in fifth_user
        visit group_path(second_group)
        expect(page).not_to have_content I18n.t('newsfeed.course.enroll')
        expect(page).not_to have_content course1.name
      end
    end
  end

  describe 'course results' do
    let(:course1) { FactoryBot.create(:course) }
    let!(:course1_completions) { FactoryBot.create(:full_completion, user: second_user, course: course1) }
    let(:second_user) { FactoryBot.create(:user, courses: [course1]) }
    let(:third_user) { FactoryBot.create(:user) }
    let(:fourth_user) { FactoryBot.create(:user) }
    let(:fifth_user) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, users: [second_user, fourth_user]) }
    let!(:second_group) { FactoryBot.create(:group, users: [second_user, fifth_user]) }
    let(:user_setting) { FactoryBot.create(:user_setting, name: :course_results_visibility, user: second_user) }
    let!(:user_setting_entry) { FactoryBot.create(:user_setting_entry, setting: user_setting, key: 'users', value: [user.id]) }
    let(:user_setting2) { FactoryBot.create(:user_setting, name: :course_results_visibility, user: second_user) }
    let!(:user_setting_entry2) { FactoryBot.create(:user_setting_entry, setting: user_setting2, key: 'groups', value: [group.id]) }

    context "with the user's profile" do
      let(:user_setting3) { FactoryBot.create(:user_setting, name: :profile_visibility, user: second_user) }
      let!(:user_setting_entry3) { FactoryBot.create(:user_setting_entry, setting: user_setting3, key: 'users', value: [user.id, third_user.id]) }
      let(:user_setting4) { FactoryBot.create(:user_setting, name: :profile_visibility, user: second_user) }
      let!(:user_setting_entry4) { FactoryBot.create(:user_setting_entry, setting: user_setting4, key: 'groups', value: [group.id, second_group.id]) }

      it 'are visible for user himself' do
        capybara_sign_in second_user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).to have_content I18n.t('users.own_profile.course_completions')
        expect(page).to have_content I18n.t('users.profile.course_completions_link')
        click_on I18n.t('users.profile.course_completions_link')
        expect(page).to have_current_path completions_path(second_user)
      end

      it 'are visible for users who are whitelisted' do
        capybara_sign_in user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).to have_content I18n.t('users.profile.course_completions')
        expect(page).to have_content I18n.t('users.profile.course_completions_link')
        click_on I18n.t('users.profile.course_completions_link')
        expect(page).to have_current_path completions_path(second_user)
      end

      it 'are not visible for users who are not whitelisted' do
        capybara_sign_in third_user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).not_to have_content I18n.t('users.profile.course_completions')
        expect(page).not_to have_content I18n.t('users.profile.course_completions_link')
      end

      it 'are visible to users who are in groups which are whitelisted' do
        capybara_sign_in fourth_user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).to have_content I18n.t('users.profile.course_completions')
        expect(page).to have_content I18n.t('users.profile.course_completions_link')
        click_on I18n.t('users.profile.course_completions_link')
        expect(page).to have_current_path completions_path(second_user)
      end

      it 'are not visible to users who are in groups which are not whitelisted' do
        capybara_sign_in fifth_user
        visit user_path(second_user)
        expect(page).to have_current_path user_path(second_user)
        expect(page).not_to have_content I18n.t('users.profile.course_completions')
        expect(page).not_to have_content I18n.t('users.profile.course_completions_link')
      end
    end

    context 'with the completions page' do
      it 'page is accessable for user himself' do
        capybara_sign_in second_user
        visit completions_path(second_user)
        expect(page).to have_current_path completions_path(second_user)
      end

      it 'page is accessable for users who are whitelisted' do
        capybara_sign_in user
        visit completions_path(second_user)
        expect(page).to have_current_path completions_path(second_user)
      end

      it 'page is not accessable for users who are not whitelisted' do
        capybara_sign_in third_user
        visit completions_path(second_user)
        expect(page).to have_current_path dashboard_path
      end

      it 'page is accessable for users who in group which are whitelisted' do
        capybara_sign_in fourth_user
        visit completions_path(second_user)
        expect(page).to have_current_path completions_path(second_user)
      end

      it 'page is not accessable for users who are in groups which are not whitelisted' do
        capybara_sign_in fifth_user
        visit completions_path(second_user)
        expect(page).to have_current_path dashboard_path
      end
    end
  end

  describe 'profile_visibility' do
    let(:second_user) { FactoryBot.create(:user) }
    let(:third_user) { FactoryBot.create(:user) }
    let(:fourth_user) { FactoryBot.create(:user) }
    let(:fifth_user) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, users: [second_user, fourth_user]) }
    let!(:second_group) { FactoryBot.create(:group, users: [second_user, fifth_user]) }
    let(:user_setting) { FactoryBot.create(:user_setting, name: :profile_visibility, user: second_user) }
    let!(:user_setting_entry) { FactoryBot.create(:user_setting_entry, setting: user_setting, key: 'users', value: [user.id]) }
    let(:user_setting2) { FactoryBot.create(:user_setting, name: :profile_visibility, user: second_user) }
    let!(:user_setting_entry2) { FactoryBot.create(:user_setting_entry, setting: user_setting2, key: 'groups', value: [group.id]) }

    it 'page is accessable for user himself' do
      capybara_sign_in second_user
      visit user_path(second_user)
      expect(page).to have_current_path user_path(second_user)
    end

    it 'page is accessable for users who are whitelisted' do
      capybara_sign_in user
      visit user_path(second_user)
      expect(page).to have_current_path user_path(second_user)
    end

    it 'page is not accessable for users who are not whitelisted' do
      capybara_sign_in third_user
      visit user_path(second_user)
      expect(page).to have_current_path dashboard_path
    end

    it 'page is accessable for users who in group which are whitelisted' do
      capybara_sign_in fourth_user
      visit user_path(second_user)
      expect(page).to have_current_path user_path(second_user)
    end

    it 'page is not accessable for users who are in groups which are not whitelisted' do
      capybara_sign_in fifth_user
      visit user_path(second_user)
      expect(page).to have_current_path dashboard_path
    end
  end
end
