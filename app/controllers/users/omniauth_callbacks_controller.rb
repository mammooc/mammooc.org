# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    protect_from_forgery except: :easy_id

    def self.provides_callback_for(provider)
      class_eval %{
      def #{provider}
        @user = User.find_for_omniauth(request.env["omniauth.auth"], current_user)

        flash['error'] ||= []
        flash['success'] ||= []

        if @user.present? && request.env["omniauth.params"].blank?
          session[:user_original_url] = user_settings_path(current_user.id) + "?subsite=account" if request.referer.present? && request.referer.include?("settings?subsite=account")
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: "#{OmniAuth::Utils.camelize(provider)}") if is_navigational_format?
        elsif @user.present? && request.env["omniauth.params"].present?
          current_user_logged_in = current_user.present?
          handle_omniauth_params
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: "#{OmniAuth::Utils.camelize(provider)}") if is_navigational_format? && !current_user_logged_in
        else
          session["devise.#{provider}_data"] = request.env["omniauth.auth"].slice('uid', 'provider')
          session["devise.#{provider}_data"]["info"] = request.env["omniauth.auth"]["info"].slice('email', 'verified', 'verified_info', 'image')
          session["devise.#{provider}_data"]["valid_until"] = Time.zone.now + 10.minutes
          redirect_to new_user_session_url
        end
      end
    }
    end

    [:facebook, :google, :github, :linkedin, :twitter, :windows_live, :amazon, :openhpi].each do |provider|
      provides_callback_for provider
    end

    def deauthorize
      flash['error'] ||= []
      flash['success'] ||= []
      if current_user.identities.count > 1 || !current_user.password_autogenerated
        begin
          UserIdentity.find_by(user: current_user, omniauth_provider: deauthorize_params[:provider]).destroy!
        rescue
          flash['error'] << if deauthorize_params[:provider] == 'easyID'
                              t('users.settings.easyID.identity_not_deleted')
                            else
                              t('users.settings.identity_not_deleted', provider: OmniAuth::Utils.camelize(deauthorize_params[:provider]))
                            end
        else
          flash['success'] << if deauthorize_params[:provider] == 'easyID'
                                t('users.settings.easyID.identity_deleted')
                              else
                                t('users.settings.identity_deleted', provider: OmniAuth::Utils.camelize(deauthorize_params[:provider]))
                              end
        end
      else
        flash['error'] << if deauthorize_params[:provider] == 'easyID'
                            t('users.settings.easyID.identity_not_deleted')
                          else
                            t('users.settings.identity_not_deleted', provider: OmniAuth::Utils.camelize(deauthorize_params[:provider]))
                          end
      end
      redirect_to "#{user_settings_path(current_user.id)}?subsite=account"
    end

    def easy_id
      if request.post?
        redirect_to "#{easy_id_path}?UID=#{easy_id_params}"
        return
      end

      # GET Request
      flash['error'] ||= []
      flash['success'] ||= []
      if easy_id_params.present?
        authentication_info = OmniAuth::AuthHash.new(
          provider: 'easyID',
          uid: easy_id_params,
          info: {},
          extra: {}
        )
        user = User.find_for_omniauth(authentication_info, current_user)
        if user.persisted?
          session[:user_original_url] = "#{user_settings_path(current_user.id)}?subsite=account" if request.referer.present? && request.referer.include?('settings?subsite=account')
          sign_in_and_redirect user, event: :authentication
          flash['success'] << t('users.sign_in_up.easyID.success')
          return
        end
      end
      flash['error'] << t('users.sign_in_up.easyID.failure')
      redirect_to new_user_session_path
    end

    private

    def handle_omniauth_params
      session.delete(:user_original_url)
      session[:user_original_url] = load_and_save_evaluation_path(request.env['omniauth.params'])
    end

    def deauthorize_params
      params.permit(:provider)
    end

    def easy_id_params
      params.permit(:UID)[:UID][0..63] if params.permit(:UID)[:UID].present?
    end
  end
end
