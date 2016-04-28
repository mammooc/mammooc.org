# encoding: utf-8
# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    def new
      self.resource = resource_class.new
    end

    def create
      flash['error'] ||= []
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        respond_with({}, {location: after_sending_reset_password_instructions_path_for(resource_name)})
      else
        redirect_to new_user_password_path
      end
    end
  end
end
