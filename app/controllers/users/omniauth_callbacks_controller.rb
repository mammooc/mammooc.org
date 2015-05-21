# -*- encoding : utf-8 -*-
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def self.provides_callback_for(provider)
      class_eval %{
      def #{provider}
        @user = User.find_for_omniauth(env["omniauth.auth"], current_user)

        if @user.persisted?
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
        else
          session["devise.#{provider}_data"] = env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    }
    end

    [:facebook].each do |provider|
      provides_callback_for provider
    end

    def after_sign_in_path_for(resource)
      if resource.email.present?
        super resource
      else
        finish_signup_path(resource)
      end
    end
  end
end
