require 'icalendar'

class UserDate < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  def self.synchronize(user)
    synchronization_state = {}
    synchronization_state[:openHPI] = OpenHPIConnector.new.load_dates_for_users [user]
    synchronization_state[:openSAP] = OpenSAPConnector.new.load_dates_for_users [user]
    synchronization_state
  end

  def self.create_current_calendar(user)
    calendar = Icalendar::Calendar.new

    user.dates.each do |user_date|
      event = Icalendar::Event.new
      event.dtstart = Icalendar::Values::Date.new((user_date.date).to_date)
      event.dtend = Icalendar::Values::Date.new((user_date.date).to_date + 1.day)
      event.summary = user_date.title
      event.description = "#{user_date.kind} for course '#{user_date.course.name}'"
      calendar.add_event(event)
    end
    calendar
  end

  def self.generate_token_for_user(user)
    if user.token_for_user_dates.blank?
      token = SecureRandom.urlsafe_base64(Settings.token_length)
      until User.find_by(token_for_user_dates: token).nil?
        token = SecureRandom.urlsafe_base64(Settings.token_length)
      end
      user.token_for_user_dates = token
      user.save
    end
  end
end
