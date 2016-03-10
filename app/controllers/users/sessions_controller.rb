# encoding: utf-8
# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def new
      flash['error'] ||= []
      self.resource = resource_class.new(sign_in_params)
      identity_mergable = false
      resource_class.omniauth_providers.each do |provider|
        next if session["devise.#{provider}_data"].blank?
        if Time.zone.now < session["devise.#{provider}_data"]['valid_until']
          session["devise.#{provider}_data"]['valid_until'] = Time.zone.now + 10.minutes
          identity_mergable = true
        else
          session.delete("devise.#{provider}_data")
        end
      end
      if identity_mergable
        flash['error'] << t('users.sign_in_up.identity_mergable', cancel: view_context.link_to(t('users.sign_in_up.identity_cancel_merge'), cancel_add_identity_path))
      end
      yield resource if block_given?
      session_infos = {}
      session_infos['first_name'] = session[:resource]['first_name'] if session[:resource].present?
      session_infos['last_name'] = session[:resource]['last_name'] if session[:resource].present?
      session_infos['primary_email'] = sign_in_params[:primary_email] || (session[:resource].present? ? session[:resource]['primary_email'] : nil)
      session[:resource] = session_infos
      respond_with(resource, serialize_options(resource))
    end

    def cancel_add_identity
      resource_class.omniauth_providers.each do |provider|
        next if session["devise.#{provider}_data"].blank?
        session.delete("devise.#{provider}_data")
      end
      redirect_to new_user_session_path
    end

    # POST /resource/sign_in
    def create
      unless params[:request_path] == new_user_session_path || params[:request_path] == new_user_registration_path || params[:request_path] == root_path
        session[:user_original_url] ||= params[:request_path]
      end
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?

      merged_providers = ''
      resource_class.omniauth_providers.each do |provider|
        next if session["devise.#{provider}_data"].blank?
        if Time.zone.now < session["devise.#{provider}_data"]['valid_until']
          User.find_for_omniauth(OmniAuth::AuthHash.new(session["devise.#{provider}_data"]), resource)
          merged_providers += "#{provider.to_s.titleize}, "
        end
        session.delete("devise.#{provider}_data")
      end
      if merged_providers.present?
        flash['success'] ||= []
        flash['success'] << t('users.sign_in_up.identity_merged', providers: merged_providers[0...-2])
      end

      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
      UserWorker.perform_async [current_user.id]
      session.delete(:user_original_url)
    end
  end

  def sign_in_params
    params.require(:user).permit(:primary_email)
  end
end
