# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Recommendation', type: :feature do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:second_user) { FactoryGirl.create(:user) }
  let!(:author) { FactoryGirl.create(:user) }
  let!(:group) { FactoryGirl.create(:group, users: [user, author, second_user]) }

  before do |example|
    unless example.metadata[:skip_before]
      visit new_user_session_path
      fill_in 'login_email', with: user.primary_email
      fill_in 'login_password', with: user.password
      click_button 'submit_sign_in'
    end

    ActionMailer::Base.deliveries.clear
  end

  describe 'delete recommendation from dashboard' do
    it 'deletes the current user from recommendation', js: true do
      user_recommendation = FactoryGirl.create(:user_recommendation, users: [user], author: author)
      visit dashboard_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(Recommendation.where(id: user_recommendation.id)).to be_empty
    end

    it 'hides the deleted recommendation', js: true do
      user_recommendation = FactoryGirl.create(:user_recommendation, users: [user], author: author)
      visit dashboard_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(user_recommendation.course.name)
    end

    it 'removes user from recommendation', js: true do
      recommendation = FactoryGirl.create(:user_recommendation, users: [user, second_user], author: author)
      visit dashboard_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
    end

    it 'does not delete recommendation', js: true do
      recommendation = FactoryGirl.create(:user_recommendation, users: [user, second_user], author: author)
      visit dashboard_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(Recommendation.find(recommendation.id).users).to match([second_user])
    end

    it 'deletes user from group recommendation', js: true do
      recommendation = FactoryGirl.create(:group_recommendation, users: [user], group: group, author: author)
      visit dashboard_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
      expect(Recommendation.find(recommendation.id).users).to be_empty
      expect(Recommendation.find(recommendation.id).group).to eq group
    end
  end

  describe 'delete recommendation from my recommendation page' do
    it 'deletes the current user from recommendation', js: true do
      user_recommendation = FactoryGirl.create(:user_recommendation, users: [user], author: author)
      visit recommendations_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(Recommendation.where(id: user_recommendation.id)).to be_empty
    end

    it 'hides the deleted recommendation', js: true do
      user_recommendation = FactoryGirl.create(:user_recommendation, users: [user], author: author)
      visit recommendations_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(user_recommendation.course.name)
    end

    it 'removes user from recommendation', js: true do
      recommendation = FactoryGirl.create(:user_recommendation, users: [user, second_user], author: author)
      visit recommendations_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
    end

    it 'does not delete recommendation', js: true do
      recommendation = FactoryGirl.create(:user_recommendation, users: [user, second_user], author: author)
      visit recommendations_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(Recommendation.find(recommendation.id).users).to match([second_user])
    end

    it 'deletes user from group recommendation', js: true do
      recommendation = FactoryGirl.create(:group_recommendation, users: [user], group: group, author: author)
      visit recommendations_path
      page.find('.remove-activity-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
      expect(Recommendation.find(recommendation.id).users).to be_empty
      expect(Recommendation.find(recommendation.id).group).to eq group
    end
  end

  describe 'delete group recommendation from groups dashboard' do
    it 'does not be possible to delete a recommendation as normal member' do
      recommendation = FactoryGirl.create(:group_recommendation, group: group, author: author)
      visit group_path(group)
      expect(page).to have_content(recommendation.course.name)
      expect(page).not_to have_selector('.remove-recommendation-group')
    end

    it 'deletes group recommendation', js: true do
      recommendation = FactoryGirl.create(:group_recommendation, group: group, author: author)
      UserGroup.set_is_admin(group.id, user.id, true)
      visit group_path(group)
      page.find('.remove-activity-group').click
      wait_for_ajax
      expect(Recommendation.where(id: recommendation.id)).to be_empty
    end

    it 'hides deleted group recommendation', js: true do
      recommendation = FactoryGirl.create(:group_recommendation, group: group, author: author)
      UserGroup.set_is_admin(group.id, user.id, true)
      visit group_path(group)
      page.find('.remove-activity-group').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
    end
  end

  describe 'delete group recommendation from groups recommendations page' do
    it 'is not possible to delete a recommendation as normal member' do
      recommendation = FactoryGirl.create(:group_recommendation, group: group, author: author)
      visit "/groups/#{group.id}/recommendations"
      expect(page).to have_content(recommendation.course.name)
      expect(page).not_to have_selector('.remove-activity-group')
    end

    it 'deletes group recommendation', js: true do
      recommendation = FactoryGirl.create(:group_recommendation, group: group, author: author)
      UserGroup.set_is_admin(group.id, user.id, true)
      visit "/groups/#{group.id}/recommendations"
      page.find('.remove-activity-group').click
      wait_for_ajax
      expect(Recommendation.where(id: recommendation.id)).to be_empty
    end

    it 'hides deleted group recommendation', js: true do
      recommendation = FactoryGirl.create(:group_recommendation, group: group, author: author)
      UserGroup.set_is_admin(group.id, user.id, true)
      visit "/groups/#{group.id}/recommendations"
      page.find('.remove-activity-group').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
    end
  end

  describe 'create recommendation' do
    let!(:course) { FactoryGirl.create(:course, name: 'qwertzui') }
    let!(:group_recommend) do
      group = FactoryGirl.create :group, users: [user, second_user], name: 'Abcdefg'
      UserGroup.set_is_admin(group.id, user.id, true)
      group
    end
    let!(:second_group_recommend) do
      group = FactoryGirl.create :group, users: [user, second_user], name: 'Abcdefg'
      UserGroup.set_is_admin(group.id, user.id, true)
      group
    end
    let!(:second_group) { FactoryGirl.create(:group, users: [third_user]) }
    let!(:third_user) { FactoryGirl.create(:user) }
    let(:user_without_group) { FactoryGirl.create(:user) }

    it 'creates new recommendation from course detail page', js: true do
      visit course_path(course)
      wait_for_ajax
      expect(Recommendation.count).to eq 0
      click_link('recommend-course-link')
      wait_for_ajax
      if ENV['PHANTOM_JS'] == 'true'
        first('.tokenfield').click
        first('.tokenfield').native.send_key(:Enter)
      else
        fill_in 'recommendation_related_group_ids-tokenfield', with: "Abc\n"
      end
      click_on I18n.t('recommendation.submit')
      expect(Recommendation.count).to eq 1
    end

    it 'creates new recommendation from group recommendation page', js: true do
      visit "/groups/#{group_recommend.id}/recommendations"
      expect(Recommendation.count).to eq 0
      click_button I18n.t('groups.recommend_course')
      wait_for_ajax
      if ENV['PHANTOM_JS'] == 'true'
        page.all('.tokenfield')[2].click
        page.all('.tokenfield')[2].native.send_keys 'qwert'
        wait_for_ajax
        page.all('.tokenfield')[2].native.send_key(:Enter)
      else
        fill_in 'recommendation_course_id-tokenfield', with: 'qwert'
        wait_for_ajax
        fill_in 'recommendation_course_id-tokenfield', with: "\n"
      end
      click_button I18n.t('recommendation.submit')
      expect(Recommendation.count).to eq 1
    end

    it 'shows in autocompletion all groups of user', js: true do
      visit new_recommendation_path
      first('.tokenfield').click
      wait_for_ajax
      user.groups.each do |group|
        expect(page).to have_content(group.name)
      end
      expect(page).not_to have_content(second_group.name)
    end

    it 'shows in autocompletion all member from all groups of user', js: true do
      visit new_recommendation_path
      page.all('.tokenfield')[1].click
      wait_for_ajax
      user.groups.each do |group|
        group.users.each do |member|
          expect(page).to have_content(member.first_name) unless user == member
        end
      end
      expect(page).not_to have_content(third_user.first_name)
    end

    it 'hides form on course detail page if user has no groups', js: true, skip_before: true do
      visit new_user_session_path
      fill_in 'login_email', with: user_without_group.primary_email
      fill_in 'login_password', with: user_without_group.password
      click_button 'submit_sign_in'
      visit course_path(course)
      wait_for_ajax
      click_link('recommend-course-link')
      wait_for_ajax
      expect(page).to have_content I18n.t('recommendation.no_groups')
      expect(page).not_to have_content I18n.t('recommendation.submit')
    end

    it 'hides form on course detail page if user is not signed in', js: true, skip_before: true do
      visit course_path(course)
      wait_for_ajax
      click_link('recommend-course-link')
      wait_for_ajax
      expect(page).to have_content I18n.t('courses.require_login')
      expect(page).to have_content I18n.t('courses.register_first')
      expect(page).not_to have_content I18n.t('recommendation.submit')
    end
  end

  describe 'create obligatory recommendation' do
    let!(:course) { FactoryGirl.create(:course, name: 'qwertzui') }
    let!(:group_obligatory) do
      group = FactoryGirl.create :group, users: [user, second_user], name: 'Abcdefg'
      UserGroup.set_is_admin(group.id, user.id, true)
      group
    end
    let!(:second_group_obligatory) do
      group = FactoryGirl.create :group, users: [user, second_user], name: 'Abcdefg'
      UserGroup.set_is_admin(group.id, user.id, true)
      group
    end
    let!(:second_group) { FactoryGirl.create(:group, users: [user, third_user]) }
    let!(:third_user) { FactoryGirl.create(:user) }

    it 'creates new obligatory recommendation from course detail page', js: true do
      visit course_path(course)
      wait_for_ajax
      expect(Recommendation.count).to eq 0
      click_link('recommend-course-obligatory-link')
      wait_for_ajax
      if ENV['PHANTOM_JS'] == 'true'
        first('.tokenfield').click
        first('.tokenfield').native.send_key(:Enter)
      else
        fill_in 'recommendation_related_group_ids-tokenfield', with: "Abc\n"
      end
      click_on I18n.t('recommendation.obligatory_recommendation.submit')
      expect(Recommendation.count).to eq 1
    end

    it 'creates new obligatory recommendation from group recommendation page', js: true do
      visit "/groups/#{group_obligatory.id}/recommendations"
      expect(Recommendation.count).to eq 0
      click_button I18n.t('groups.recommend_course_obligatory')
      wait_for_ajax
      if ENV['PHANTOM_JS'] == 'true'
        page.all('.tokenfield')[2].click
        page.all('.tokenfield')[2].native.send_keys 'qwert'
        wait_for_ajax
        page.all('.tokenfield')[2].native.send_key(:Enter)
      else
        fill_in 'recommendation_course_id-tokenfield', with: 'qwert'
        wait_for_ajax
        fill_in 'recommendation_course_id-tokenfield', with: "\n"
      end
      click_button I18n.t('recommendation.obligatory_recommendation.submit')
      expect(Recommendation.count).to eq 1
    end

    it 'shows button on group recommendation page for admins' do
      visit "/groups/#{group_obligatory.id}/recommendations"
      expect(page).to have_content I18n.t('groups.recommend_course_obligatory')
    end

    it 'hides button on group recommendation page for normal members', skip_before: true do
      visit new_user_session_path
      fill_in 'login_email', with: second_user.primary_email
      fill_in 'login_password', with: second_user.password
      click_button 'submit_sign_in'
      visit "/groups/#{group_obligatory.id}/recommendations"
      expect(page).not_to have_content I18n.t('groups.recommend_course_obligatory')
    end

    it 'shows in autocompletion only groups for which user is admin', js: true do
      visit '/recommendations/new?is_obligatory=true'
      first('.tokenfield').click
      wait_for_ajax
      expect(page).to have_content(group_obligatory.name)
      expect(page).to have_content(second_group_obligatory.name)
      expect(page).not_to have_content(second_group.name)
    end

    it 'shows in autocompletion only member from groups for which user is admin', js: true do
      visit '/recommendations/new?is_obligatory=true'
      page.all('.tokenfield')[1].click
      wait_for_ajax
      expect(page).to have_content(second_user.first_name)
      expect(page).not_to have_content(third_user.first_name)
    end

    it 'hides form on course detail page if user has no groups for which he is admin', js: true, skip_before: true do
      visit new_user_session_path
      fill_in 'login_email', with: third_user.primary_email
      fill_in 'login_password', with: third_user.password
      click_button 'submit_sign_in'
      visit course_path(course)
      wait_for_ajax
      click_link('recommend-course-obligatory-link')
      wait_for_ajax
      expect(page).to have_content I18n.t('recommendation.no_admin_groups')
      expect(page).not_to have_content I18n.t('groups.recommend_course_obligatory')
    end

    it 'hides form on course detail page if user is not signed in', js: true, skip_before: true do
      visit course_path(course)
      wait_for_ajax
      click_link('recommend-course-obligatory-link')
      wait_for_ajax
      expect(page).to have_content I18n.t('courses.require_login')
      expect(page).to have_content I18n.t('courses.register_first')
      expect(page).not_to have_content I18n.t('groups.recommend_course_obligatory')
    end
  end
end
