# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'support/feature_support'

RSpec.describe 'Activities', type: :feature do
  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    capybara_sign_in user

    ActionMailer::Base.deliveries.clear
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  describe 'create activity' do
    let(:second_user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, users: [user]) }
    #let(:group_join) { FactoryGirl.create(:activity_group_join, group_ids: [group.id], user_ids: [group.users.collect(&:id)], owner_id: second_user.id) }
    #let(:course_enroll) { FactoryGirl.create(:activity_course_enroll, group_ids: [group.id], user_ids: [group.users.collect(&:id)], owner_id: second_user.id) }
    #let(:bookmark) { FactoryGirl.create(:activity_bookmark, group_ids: [group.id], user_ids: [group.users.collect(&:id)], owner_id: second_user.id) }
    #let(:group_recommendation) { FactoryGirl.create(:activity_group_recommendation) }
    #let(:user_recommendation) { FactoryGirl.create(:activity_user_recommendation) }

    context 'join a group' do
      let(:invitation) { FactoryGirl.create(:group_invitation, group: group) }

      before(:each) do
        capybara_sign_out user
        capybara_sign_in second_user
        visit "/groups/join/#{invitation.token}"
        capybara_sign_out second_user
        capybara_sign_in user
      end

      it 'creates activity after joining a group' do
        expect(group.reload.users).to match_array([user, second_user])
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'is shown on dashboard' do
        visit dashboard_dashboard_path
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name}"
        expect(page).to have_content I18n.t('newsfeed.group.join.no_group_context2')
      end

      it 'is shown on group dashboard' do
        visit group_path(group)
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name}"
        expect(page).to have_content I18n.t('newsfeed.group.join.group_context')
      end

      it 'is not shown on owner dashboard' do
        capybara_sign_out user
        capybara_sign_in second_user
        visit dashboard_dashboard_path
        expect(page).not_to have_content I18n.t('newsfeed.group.join.no_group_context2')
      end
    end

    context 'bookmark a course' do
      let(:course) { FactoryGirl.create(:course) }
      let!(:group_one) { FactoryGirl.create(:group, users: [user, second_user]) }

      before(:each) do
        capybara_sign_out user
        capybara_sign_in second_user
        visit course_path(course)
        click_on 'bookmark-link'
        wait_for_ajax
        capybara_sign_out second_user
        capybara_sign_in user
      end

      it 'creates activity after bookmark a course', js:true do
        expect(Bookmark.count).to eq 1
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'is shown on dashboard', js: true do
        group_one
        visit dashboard_dashboard_path
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name}"
        expect(page).to have_content I18n.t('newsfeed.bookmark.create')
      end

      it 'is shown on group dashboard', js: true do
        visit group_path(group)
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name}"
        expect(page).to have_content I18n.t('newsfeed.bookmark.create')
      end

      it 'is not shown on owner dashboard', js: true do
        capybara_sign_out user
        capybara_sign_in second_user
        visit dashboard_dashboard_path
        expect(page).not_to have_content I18n.t('newsfeed.bookmark.create')
      end
    end

    context 'enroll in course' do
      let(:openHPI) { FactoryGirl.create(:mooc_provider, name: 'openHPI', api_support_state: 'naive') }
      let(:course) { FactoryGirl.create(:course, mooc_provider: openHPI) }
      let!(:group) { FactoryGirl.create(:group, users: [user, second_user]) }

      before(:each) do
        expect_any_instance_of(OpenHPIConnector).to receive(:enroll_user_for_course).and_return(true)
        capybara_sign_out user
        capybara_sign_in second_user
        visit course_path(course)
        click_link('enroll-link')
        wait_for_ajax
        capybara_sign_out second_user
        capybara_sign_in user
      end

      it 'creates activity after enroll in a course', js: true do
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'is shown on dashboard', js: true do
        visit dashboard_dashboard_path
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name}"
        expect(page).to have_content I18n.t('newsfeed.course.enroll')
      end

      it 'is shown on group dashboard', js: true do
        visit group_path(group)
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name}"
        expect(page).to have_content I18n.t('newsfeed.course.enroll')
      end

      it 'is not shown on owner dashboard', js: true do
        capybara_sign_out user
        capybara_sign_in second_user
        visit dashboard_dashboard_path
        expect(page).not_to have_content I18n.t('newsfeed.course.enroll')
      end
    end

    context 'recommend a course' do
      let(:course) { FactoryGirl.create(:course) }
      let!(:group) { FactoryGirl.create(:group, users: [user, second_user]) }

      before(:each) do
        capybara_sign_out user
        capybara_sign_in second_user
        visit course_path(course)
        wait_for_ajax
        click_link('recommend-course-link')
        wait_for_ajax
        if ENV['PHANTOM_JS'] == 'true'
          first('.tokenfield').click
          first('.tokenfield').native.send_key(:Enter)
        else
          fill_in 'recommendation_related_group_ids-tokenfield', with: "#{group.name}\n"
        end
        click_on I18n.t('recommendation.submit')
        capybara_sign_out second_user
        capybara_sign_in user
      end

      it 'creates activity after recommend a course', js:true do
        expect(Recommendation.count).to eq 1
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'is shown on dashboard', js:true do
        visit dashboard_dashboard_path
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name}"
        expect(page).to have_content I18n.t('recommendation.for_you')
      end

      it 'is shown on group dashboard', js:true do
        visit group_path(group)
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name}"
        expect(page).to have_content I18n.t('recommendation.for_group')
      end

      it 'is not shown on owner dashboard', js:true do
        capybara_sign_out user
        capybara_sign_in second_user
        visit dashboard_dashboard_path
        expect(page).not_to have_content I18n.t('recommendation.for_you')
      end
    end

  end

end
