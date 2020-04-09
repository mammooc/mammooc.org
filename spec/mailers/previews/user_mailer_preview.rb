# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def newsletter_for_new_courses
    user = User.first
    user.newsletter_interval = 5 if user.newsletter_interval.blank?
    user.unsubscribed_newsletter = true if user.unsubscribed_newsletter.blank?
    user.last_newsletter_send_at = Time.zone.today - user.newsletter_interval.days if user.last_newsletter_send_at.nil?
    courses = User.collect_new_courses(user)
    courses = [Course.first] if courses.blank?
    UserMailer.newsletter_for_new_courses(user.primary_email, user, courses)
  end
end
