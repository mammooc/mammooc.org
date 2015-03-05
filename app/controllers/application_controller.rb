class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_login
  before_filter :set_language

  def after_sign_in_path_for(resource)
    sign_in_url = new_user_session_url
    if session[:user_original_url] == sign_in_url
      super
    else
      stored_location_for(resource) || session[:user_original_url] || root_path
    end
  end

  private

  def set_language
    locale = http_accept_language.compatible_language_from(I18n.available_locales)
    if session[:language] and I18n.available_locales.include? session[:language].to_sym
      locale = session[:language]
    end
    if params[:language] and I18n.available_locales.include? params[:language].to_sym
      locale = params[:language]
      session[:language] = locale
    end
    I18n.locale = locale
  end

  def require_login
    unless user_signed_in?
      flash[:error] = t('require_login')
      session[:user_original_url] = request.fullpath
      redirect_to new_user_session_path # halts request cycle
    end
  end

  def language_names
    {de: 'Deutsch', en: 'English'}
  end
  helper_method 'language_names'

end
