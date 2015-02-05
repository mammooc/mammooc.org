class Users::RegistrationsController < Devise::RegistrationsController

  #before_action :add_resource
  #after_action :invalidate_resource

  def new
     super
  end

  def create
    if (user_params.has_key?(:terms_and_conditions_confirmation))
      super
      #@user = User.new(user_params)
      #@user.save()
    else
      flash['error'] = t('terms_and_conditions_failure')

      build_resource(sign_up_params)
      resource.save
      clean_up_passwords resource
      #set_minimum_password_length
      #render :method => 'GET', action: :new
      session[:resource] = resource
      redirect_to new_user_registration_path
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
