require 'devise_helper'

class Users::RegistrationsController < Devise::RegistrationsController

  #before_action :add_resource
  #after_action :invalidate_resource

  def new
     super
  end

  def create

      flash['error'] ||= []
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?
      if resource.persisted?  && user_params.has_key?(:terms_and_conditions_confirmation)
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        session[:resource] = resource

        resource.errors.each do |key, value|
          flash['error'] << "#{t(key)} #{value}"
        end
        redirect_to new_user_registration_path
      end

      if (not user_params.has_key?(:terms_and_conditions_confirmation))
        flash['error'] << t('terms_and_conditions_failure')
      end

  end


  # protected
  #   def configure_permitted_parameters
  #     devise_parameter_sanitizer.for(:sign_up).push(:first_name)
  #   end

  private
    def sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def user_params
      params.permit(:terms_and_conditions_confirmation)
    end


    def add_resource
      @resource = session[:resource]
    end

    def invalidate_resource
      session.delete(:resource)
    end

end
