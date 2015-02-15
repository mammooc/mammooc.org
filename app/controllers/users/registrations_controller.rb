class Users::RegistrationsController < Devise::RegistrationsController


  def new
     super
  end

  def create
    super
    @user = User.new(user_params)
    @user.save()
  end

  protected
  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  def after_update_path_for(resource)
    after_sign_in_path_for(resource)
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
      params.require(:user).permit(:first_name, :last_name, :email)
    end

end
