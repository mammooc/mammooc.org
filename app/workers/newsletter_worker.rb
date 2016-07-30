# frozen_string_literal: true
class NewsletterWorker
  include Sidekiq::Worker

  def perform
    send_email_with_new_courses
  end

  def send_email_with_new_courses
    User.all.each do |user|
      next if user.unsubscribed_newsletter || user.unsubscribed_newsletter.nil?
      if user.last_newsletter_send_at.present? && (user.last_newsletter_send_at + user.newsletter_interval.days).to_date > Time.zone.today
        next
      end
      if user.last_newsletter_send_at.nil?
        user.last_newsletter_send_at = Time.zone.now - user.newsletter_interval.days
      end
      courses = User.collect_new_courses(user)
      next unless courses.present?
      UserMailer.newsletter_for_new_courses(user.primary_email, user, courses).deliver_now
      user.last_newsletter_send_at = Time.zone.now
      user.save
    end
  end
end
