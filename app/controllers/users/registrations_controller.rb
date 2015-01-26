class Users::RegistrationsController < Devise::RegistrationsController


  def new
     super
  end

  def create
    @user = User.new(user_params)
    puts user_params
    super
    @user.save()
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
