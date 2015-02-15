class Users::PasswordsController < Devise::PasswordsController
  # def new
  #   super
  # end

  # def create
  #   super
  # end

  protected
  def after_resetting_password_path_for(resource)
    after_sign_in_path_for(resource)
  end

end
