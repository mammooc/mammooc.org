# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'Bookmark', type: :feature do
  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    visit new_user_session_path
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'

    ActionMailer::Base.deliveries.clear
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  describe 'bookmark course on course detail page' do
    let(:course) { FactoryGirl.create(:course) }

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
    let(:course) { FactoryGirl.create(:course) }
    let!(:bookmark) { FactoryGirl.create(:bookmark, user: user, course: course) }

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
    let!(:course) { FactoryGirl.create(:course) }
    let!(:author) { FactoryGirl.create(:user) }
    let!(:group) { FactoryGirl.create(:group, users: [user, author]) }
    let!(:recommendation) { FactoryGirl.create(:user_recommendation, course: course, users: [user], author: author, group: nil) }

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
    let(:course) { FactoryGirl.create(:course) }
    let!(:author) { FactoryGirl.create(:user) }
    let!(:group) { FactoryGirl.create(:group, users: [user, author]) }
    let!(:recommendation) { FactoryGirl.create(:user_recommendation, author: author, course: course, users: [user]) }
    let!(:bookmark) { FactoryGirl.create(:bookmark, user: user, course: course) }

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
    let(:course) { FactoryGirl.create(:course) }
    let(:second_course) { FactoryGirl.create(:course, name: 'Kurs 2') }
    let!(:bookmark) { FactoryGirl.create(:bookmark, course: course, user: user) }
    let!(:second_bookmark) { FactoryGirl.create(:bookmark, course: second_course, user: user) }

    it 'deletes bookmark', js: true do
      visit bookmarks_path
      first('.glyphicon-remove').click
      wait_for_ajax
      expect(Bookmark.count).to eq 1
    end

    it 'hides only deleted bookmark entry', js: true do
      visit bookmarks_path
      find("a[data-course_id='#{course.id}']").find('.glyphicon-remove').click
      wait_for_ajax
      expect(page).to have_content(I18n.t('dashboard.bookmarks'))
      expect(page).to have_content second_bookmark.course.name
      expect(page).not_to have_content bookmark.course.name
    end
  end
end
