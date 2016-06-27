# frozen_string_literal: true
class UserMailerPreview < ActionMailer::Preview
  def newsletter_for_new_courses
    user = User.find_by(first_name: 'Max')
    if user.newsletter_interval.blank?
      user.newsletter_interval=5
    end
    if user.unsubscribed_newsletter.blank?
      user.unsubscribed_newsletter = true
    end
    if user.last_newsletter_send_at.nil?
      user.last_newsletter_send_at = Time.zone.today - user.newsletter_interval.days
    end
    courses = User.collect_new_courses(user)
    if courses.present?
      UserMailer.newsletter_for_new_courses(user.primary_email, user, courses)
    end
  end
end
