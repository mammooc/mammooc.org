# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookmark', type: :feature do
  let(:user) { FactoryBot.create(:user) }

  before do
    visit new_user_session_path
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'

    ActionMailer::Base.deliveries.clear
  end

  describe 'bookmark course on course detail page' do
    let(:course) { FactoryBot.create(:course) }

    it 'creates a new bookmark', js: true do
      visit course_path(course)
      click_on 'bookmark-link'
      wait_for_ajax
      expect(Bookmark.count).to be 1
    end

    it 'changes text of button', js: true do
      visit course_path(course)
      click_on 'bookmark-link'
      wait_for_ajax
      expect(find('.action-icon-wishlist')['data-original-title']).to eq(I18n.t('courses.course-list.remove-bookmark'))
    end
  end

  describe 'delete bookmark for a course on course detail page' do
    let(:course) { FactoryBot.create(:course) }
    let!(:bookmark) { FactoryBot.create(:bookmark, user: user, course: course) }
    let!(:activity_bookmark) { FactoryBot.create(:activity_bookmark, trackable_id: bookmark.id, owner_id: user.id) }

    it 'deletes the specified bookmark', js: true do
      visit course_path(course)
      click_on 'remove-bookmark-link'
      wait_for_ajax
      expect(Bookmark.count).to be 0
    end

    it 'changes text of button', js: true do
      visit course_path(course)
      click_on 'remove-bookmark-link'
      wait_for_ajax
      expect(find('.action-icon-wishlist')['data-original-title']).to eq(I18n.t('courses.course-list.bookmark'))
    end
  end

  describe 'bookmark course directly from recommendation' do
    let!(:course) { FactoryBot.create(:course) }
    let!(:author) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, users: [user, author]) }
    let!(:recommendation) { FactoryBot.create(:user_recommendation, course: course, users: [user], author: author, group: nil) }

    it 'creates a new bookmark', js: true do
      visit dashboard_dashboard_path
      click_on 'remember_course_link'
      wait_for_ajax
      expect(Bookmark.count).to be 1
    end

    it 'changes text of button', js: true do
      visit dashboard_dashboard_path
      click_on 'remember_course_link'
      wait_for_ajax
      expect(page).to have_content I18n.t('courses.delete_remember_course')
      expect(page).not_to have_content I18n.t('courses.remember_course')
    end
  end

  describe 'delete bookmark for a course directly from recommendation' do
    let(:course) { FactoryBot.create(:course) }
    let!(:author) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, users: [user, author]) }
    let!(:recommendation) { FactoryBot.create(:user_recommendation, author: author, course: course, users: [user]) }
    let!(:bookmark) { FactoryBot.create(:bookmark, user: user, course: course) }
    let!(:activity_bookmark) { FactoryBot.create(:activity_bookmark, trackable_id: bookmark.id, owner_id: user.id) }

    it 'deletes the specified bookmark', js: true do
      visit dashboard_dashboard_path
      click_on 'delete_remember_course_link'
      wait_for_ajax
      expect(Bookmark.count).to be 0
    end

    it 'changes text of button', js: true do
      visit dashboard_dashboard_path
      click_on 'delete_remember_course_link'
      wait_for_ajax
      expect(page).to have_content I18n.t('courses.remember_course')
      expect(page).not_to have_content I18n.t('courses.delete_remember_course')
    end
  end

  describe 'delete bookmark from bookmark list' do
    let(:course) { FactoryBot.create(:course) }
    let(:second_course) { FactoryBot.create(:course, name: 'Kurs 2') }
    let!(:bookmark) { FactoryBot.create(:bookmark, course: course, user: user) }
    let!(:second_bookmark) { FactoryBot.create(:bookmark, course: second_course, user: user) }
    let!(:activity_bookmark) { FactoryBot.create(:activity_bookmark, trackable_id: bookmark.id, owner_id: user.id) }
    let!(:activity_second_bookmark) { FactoryBot.create(:activity_bookmark, trackable_id: second_bookmark.id, owner_id: user.id) }

    it 'deletes bookmark', js: true do
      visit bookmarks_path
      if ENV['PHANTOM_JS'] == 'true'
        first('.glyphicon-remove').trigger('click')
      else
        first('.glyphicon-remove').click
      end
      wait_for_ajax
      expect(Bookmark.count).to eq 1
    end

    it 'hides only deleted bookmark entry', js: true do
      visit bookmarks_path
      if ENV['PHANTOM_JS'] == 'true'
        find("a[data-course_id='#{course.id}']").find('.glyphicon-remove').trigger('click')
      else
        find("a[data-course_id='#{course.id}']").find('.glyphicon-remove').click
      end
      wait_for_ajax
      expect(page).to have_content(I18n.t('dashboard.bookmarks'))
      expect(page).to have_content second_bookmark.course.name
      expect(page).not_to have_content bookmark.course.name
    end
  end
end
