# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def xikolo_api_expiration(email_adress, worker_name, request, api_expiration_date, root_url)
    return if email_adress.blank?
    @worker_name = worker_name
    @request = request
    @api_expiration_date = api_expiration_date
    @root_url = root_url
    mail(to: email_adress, subject: "X-Api-Version-Expiration-Date: #{@api_expiration_date} - #{@worker_name}")
  end
end
