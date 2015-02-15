class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_login

  def after_sign_in_path_for(resource)
    sign_in_url = new_user_session_url
    if session[:user_original_url] == sign_in_url
      super
    else
      stored_location_for(resource) || session[:user_original_url] || root_path
    end
  end

  private

  def require_login
    unless user_signed_in?
        session[:user_original_url] = request.fullpath
      flash[:error] = "You must be logged in to access this section"
      redirect_to new_user_session_path # halts request cycle
    end
  end

end