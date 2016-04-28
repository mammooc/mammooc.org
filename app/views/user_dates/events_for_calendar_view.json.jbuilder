# encoding: utf-8
# frozen_string_literal: true

json.array!(@current_user_dates) do |user_date|
  json.title user_date.title
  json.allDay :true
  json.start user_date.date
end
