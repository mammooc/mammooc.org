# frozen_string_literal: true
require 'rails_helper'
require 'support/feature_support'

RSpec.describe 'Activities', type: :feature do
  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }
  let(:second_user) { FactoryGirl.create(:user) }

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

  context 'join a group' do
    let(:second_user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, users: [user]) }
    let(:invitation) { FactoryGirl.create(:group_invitation, group: group) }

    before(:each) do
      capybara_sign_out user
      capybara_sign_in second_user
      visit "/groups/join/#{invitation.token}"
      capybara_sign_out second_user
      capybara_sign_in user
    end

    describe 'create activity' do
      it 'creates activity after joining a group' do
        expect(group.reload.users).to match_array([user, second_user])
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'is shown on dashboard' do
        visit dashboard_dashboard_path
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('newsfeed.group.join.no_group_context1')} #{group.name} #{I18n.t('newsfeed.group.join.no_group_context2')}"
      end

      it 'is shown on group dashboard' do
        visit group_path(group)
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('newsfeed.group.join.group_context')}"
      end

      it 'is not shown on owner dashboard' do
        capybara_sign_out user
        capybara_sign_in second_user
        visit dashboard_dashboard_path
        expect(page).not_to have_content "#{I18n.t('newsfeed.group.join.no_group_context1')} #{group.name} #{I18n.t('newsfeed.group.join.no_group_context2')}"
      end
    end

    describe 'ignore activity' do
      let(:another_user) { FactoryGirl.create(:user) }
      let!(:activity) do
        activity = PublicActivity::Activity.first
        activity.user_ids.push(another_user.id)
        activity.save
        activity
      end

      it 'hides activity on users dashboard', js: true do
        visit dashboard_dashboard_path
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 1
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
      end

      it 'is not possible to ignore activity in group if user is not admin', js: true do
        visit group_path(group)
        expect(page).not_to have_content I18n.t('newsfeed.button.ignore')
      end

      it 'hides activity if user is admin', js: true do
        UserGroup.set_is_admin(group.id, user.id, true)
        visit group_path(group)
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 1
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
      end

      it 'deletes activity if last user ignores', js: true do
        activity.user_ids -= [another_user.id]
        activity.group_ids = []
        activity.save
        visit dashboard_dashboard_path
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 0
      end

      it 'deletes activity if last group ignores', js: true do
        UserGroup.set_is_admin(group.id, user.id, true)
        activity.user_ids = []
        activity.save
        visit group_path(group)
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 0
      end
    end
  end

  context 'bookmark a course' do
    let(:course) { FactoryGirl.create(:course) }
    let!(:group) { FactoryGirl.create(:group, users: [user, second_user]) }

    before(:each) do
      capybara_sign_out user
      capybara_sign_in second_user
      visit course_path(course)
      click_on 'bookmark-link'
      wait_for_ajax
      capybara_sign_out second_user
      capybara_sign_in user
    end

    describe 'create activity' do
      it 'creates activity after bookmark a course', js: true do
        expect(Bookmark.count).to eq 1
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'is shown on dashboard', js: true do
        visit dashboard_dashboard_path
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('newsfeed.bookmark.create')}"
      end

      it 'is shown on group dashboard', js: true do
        visit group_path(group)
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('newsfeed.bookmark.create')}"
      end

      it 'is not shown on owner dashboard', js: true do
        capybara_sign_out user
        capybara_sign_in second_user
        visit dashboard_dashboard_path
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
        expect(page).not_to have_content I18n.t('newsfeed.bookmark.create')
      end
    end

    describe 'ignore activity' do
      let(:another_user) { FactoryGirl.create(:user) }
      let!(:activity) do
        activity = PublicActivity::Activity.first
        activity.user_ids.push(another_user.id)
        activity.save
        activity
      end

      it 'hides activity on users dashboard', js: true do
        visit dashboard_dashboard_path
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 1
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
      end

      it 'is not possible to ignore activity in group if user is not admin', js: true do
        visit group_path(group)
        expect(page).not_to have_content I18n.t('newsfeed.button.ignore')
      end

      it 'hides activity if user is admin', js: true do
        UserGroup.set_is_admin(group.id, user.id, true)
        visit group_path(group)
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 1
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
      end

      it 'deletes activity if last user ignores', js: true do
        activity.user_ids -= [another_user.id]
        activity.group_ids = []
        activity.save
        visit dashboard_dashboard_path
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 0
      end

      it 'deletes activity if last group ignores', js: true do
        UserGroup.set_is_admin(group.id, user.id, true)
        activity.user_ids = []
        activity.save
        visit group_path(group)
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 0
      end
    end
  end

  context 'enroll in course' do
    let(:openHPI) { FactoryGirl.create(:mooc_provider, name: 'openHPI', api_support_state: 'naive') }
    let(:course) { FactoryGirl.create(:course, mooc_provider: openHPI) }
    let!(:group) { FactoryGirl.create(:group, users: [user, second_user]) }
    let(:user_setting) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: second_user) }
    let!(:user_setting_entry) { FactoryGirl.create(:user_setting_entry, setting: user_setting, key: 'groups', value: [group.id]) }

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

    describe 'create activity' do
      it 'creates activity after enroll in a course', js: true do
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'is shown on dashboard', js: true do
        visit dashboard_dashboard_path
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('newsfeed.course.enroll')}"
        expect(page).to have_content I18n.t('newsfeed.course.enroll')
      end

      it 'is shown on group dashboard', js: true do
        visit group_path(group)
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('newsfeed.course.enroll')}"
      end

      it 'is not shown on owner dashboard', js: true do
        capybara_sign_out user
        capybara_sign_in second_user
        visit dashboard_dashboard_path
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
        expect(page).not_to have_content I18n.t('newsfeed.course.enroll')
      end
    end

    describe 'ignore activity' do
      let(:another_user) { FactoryGirl.create(:user) }
      let!(:activity) do
        activity = PublicActivity::Activity.first
        activity.user_ids.push(another_user.id)
        activity.save
        activity
      end

      it 'hides activity on users dashboard', js: true do
        visit dashboard_dashboard_path
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 1
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
      end

      it 'is not possible to ignore activity in group if user is not admin', js: true do
        visit group_path(group)
        expect(page).not_to have_content I18n.t('newsfeed.button.ignore')
      end

      it 'hides activity if user is admin', js: true do
        UserGroup.set_is_admin(group.id, user.id, true)
        visit group_path(group)
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 1
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
      end

      it 'deletes activity if last user ignores', js: true do
        activity.user_ids -= [another_user.id]
        activity.group_ids = []
        activity.save
        visit dashboard_dashboard_path
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 0
      end

      it 'deletes activity if last group ignores', js: true do
        UserGroup.set_is_admin(group.id, user.id, true)
        activity.user_ids = []
        activity.save
        visit group_path(group)
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 0
      end
    end
  end

  context 'recommend a course to a group' do
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
      wait_for_ajax
      click_on I18n.t('recommendation.submit')
      capybara_sign_out second_user
      capybara_sign_in user
    end

    describe 'create activity' do
      it 'creates activity after recommend a course', js: true do
        expect(Recommendation.count).to eq 1
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'is shown on dashboard', js: true do
        visit dashboard_dashboard_path
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('recommendation.for_group')} #{group.name}"
      end

      it 'is shown on users recommendation page', js: true do
        visit recommendations_path
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('recommendation.for_group')} #{group.name}"
      end

      it 'is shown on group dashboard', js: true do
        visit group_path(group)
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('recommendation.for_group')}  #{group.name}"
      end

      it 'is shown on groups recommendation page', js: true do
        visit "/groups/#{group.id}/recommendations"
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('recommendation.for_group')}  #{group.name}"
      end

      it 'is not shown on owner dashboard', js: true do
        capybara_sign_out user
        capybara_sign_in second_user
        visit dashboard_dashboard_path
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
        expect(page).not_to have_content I18n.t('recommendation.for_group')
      end
    end

    describe 'ignore activity' do
      let(:another_user) { FactoryGirl.create(:user) }
      let!(:activity) do
        activity = PublicActivity::Activity.first
        activity.user_ids.push(another_user.id)
        activity.save
        activity
      end

      it 'hides activity on users dashboard', js: true do
        visit dashboard_dashboard_path
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 1
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
      end

      it 'is not possible to ignore activity in group if user is not admin', js: true do
        visit group_path(group)
        expect(page).not_to have_content I18n.t('newsfeed.button.ignore')
      end

      it 'hides activity if user is admin', js: true do
        UserGroup.set_is_admin(group.id, user.id, true)
        visit group_path(group)
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 1
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
      end

      it 'deletes activity if last group ignores', js: true do
        UserGroup.set_is_admin(group.id, user.id, true)
        activity.user_ids = []
        activity.save
        visit group_path(group)
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 0
      end
    end
  end

  context 'recommend a course to a user' do
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
        page.all('.tokenfield')[1].click
        page.all('.tokenfield')[1].native.send_key(:Enter)
      else
        fill_in 'recommendation_related_user_ids-tokenfield', with: "#{user.first_name}\n"
      end
      click_on I18n.t('recommendation.submit')
      capybara_sign_out second_user
      capybara_sign_in user
    end

    describe 'create activity' do
      it 'creates activity after recommend a course', js: true do
        expect(Recommendation.count).to eq 1
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'is shown on dashboard', js: true do
        visit dashboard_dashboard_path
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('recommendation.for_you')}"
      end

      it 'is shown on users recommendation page', js: true do
        visit recommendations_path
        expect { find('.newsfeed') }.not_to raise_error
        expect(page).to have_content "#{second_user.first_name} #{second_user.last_name} #{I18n.t('recommendation.for_you')}"
      end

      it 'is not shown on owner dashboard', js: true do
        capybara_sign_out user
        capybara_sign_in second_user
        visit dashboard_dashboard_path
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
        expect(page).not_to have_content I18n.t('recommendation.for_group')
      end
    end

    describe 'ignore activity' do
      let(:another_user) { FactoryGirl.create(:user) }
      let!(:activity) do
        activity = PublicActivity::Activity.first
        activity.user_ids.push(another_user.id)
        activity.save
        activity
      end

      it 'hides activity on users dashboard', js: true do
        visit dashboard_dashboard_path
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 1
        expect { find('.newsfeed') }.to raise_error Capybara::ElementNotFound
      end

      it 'deletes activity if last user ignores', js: true do
        activity.user_ids -= [another_user.id]
        activity.group_ids = []
        activity.save
        visit dashboard_dashboard_path
        click_on I18n.t('newsfeed.button.ignore')
        wait_for_ajax
        expect(PublicActivity::Activity.count).to eq 0
      end
    end
  end
end
