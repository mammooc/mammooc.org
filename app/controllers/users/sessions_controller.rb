# -*- encoding : utf-8 -*-
module Users
  class SessionsController < Devise::SessionsController
    def new
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      yield resource if block_given?
      respond_with(resource, serialize_options(resource))
    end

    # POST /resource/sign_in
    def create
      unless params[:request_path] == new_user_session_path || params[:request_path] == new_user_registration_path || params[:request_path] == root_path
        session[:user_original_url] ||= params[:request_path]
      end
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
      UserWorker.perform_async [current_user.id]
      session.delete(:user_original_url)
    end
  end
end
