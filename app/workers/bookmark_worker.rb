# encoding: utf-8
# frozen_string_literal: true

class BookmarkWorker
  include Sidekiq::Worker

  def perform
    send_reminder_for_bookmarked_courses
  end

  def send_reminder_for_bookmarked_courses
    courses_to_remind = Course.where(start_date: Time.zone.today + 1.week)
    bookmarks_to_remind = Bookmark.where(course: courses_to_remind)
    bookmarks_to_remind.each do |bookmark|
      UserMailer.reminder_for_bookmarked_course(bookmark.user.primary_email, bookmark.user, bookmark.course).deliver_later
    end
  end
end
