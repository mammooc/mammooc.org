# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  include ConnectorMapper
  before_action :set_provider_logos, only: [:settings, :mooc_provider_settings]
  load_and_authorize_resource only: [:show, :edit, :update, :destroy, :finish_signup]

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path, alert: t("unauthorized.#{exception.action}.user") }
      format.json do
        error = {message: exception.message, action: exception.action, subject: exception.subject.id}
        render json: error.to_json, status: :unauthorized
      end
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user_picture = current_user.profile_image.expiring_url(3600, :square)
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: t('flash.notice.users.successfully_updated') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    unless UserGroup.find_by_user_id(@user.id).blank?
      UserGroup.find_by_user_id(@user.id).destroy
    end
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: t('flash.notice.users.successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  def synchronize_courses
    @synchronization_state = {}
    @synchronization_state[:open_hpi] = OpenHPIUserWorker.new.perform [current_user.id]
    @synchronization_state[:open_sap] = OpenSAPUserWorker.new.perform [current_user.id]
    if CourseraUserWorker.new.perform [current_user.id]
      @synchronization_state[:coursera] = true
    else
      @synchronization_state[:coursera] = CourseraConnector.new.oauth_link(synchronize_courses_path(current_user), masked_authenticity_token(session))
    end
    @partial = render_to_string partial: 'dashboard/user_courses', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :synchronization_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def account_settings
    @user = current_user
    @emails = @user.emails.sort_by do |email|
      [email.is_primary ? 0 : 1, email.address]
    end
    @partial = render_to_string partial: 'users/form', formats: [:html]
    @partial += render_to_string partial: 'users/change_emails', formats: [:html]
    @partial += render_to_string partial: 'devise/registrations/edit', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :settings, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def mooc_provider_settings
    prepare_mooc_provider_settings

    @partial = render_to_string partial: 'users/mooc_provider_settings', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :settings, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def settings
    #session[:deleted_user_emails] = []
    prepare_mooc_provider_settings
    @subsite = params['subsite']
    @user = current_user
    @emails = @user.emails.sort_by do |email|
      [email.is_primary ? 0 : 1, email.address]
    end

  end

  def oauth_callback
    code = params[:code]
    state = params[:state].split(/~/)
    mooc_provider = MoocProvider.find_by_name(state.first)
    destination_path = state.second
    csrf_token = state.third
    flash['error'] ||= []

    return oauth_error_and_redirect(destination_path) if mooc_provider.blank?

    provider_connector = get_connector_by_mooc_provider mooc_provider

    return oauth_error_and_redirect(destination_path) if provider_connector.blank? && mooc_provider.api_support_state != 'oauth'

    if params[:error].present? || !valid_authenticity_token?(session, csrf_token)
      provider_connector.destroy_connection(current_user)
      return oauth_error_and_redirect(destination_path)
    elsif code.present?
      provider_connector.initialize_connection(current_user, code: code)
      redirect_to destination_path
    end
  end

  def oauth_error_and_redirect(destination_path)
    flash['error'] << "#{t('users.synchronization.oauth_error')}"
    redirect_to destination_path
  end

  def set_mooc_provider_connection
    @got_connection = false
    mooc_provider = MoocProvider.find_by_id(params[:mooc_provider])
    if mooc_provider.present?
      provider_connector = get_connector_by_mooc_provider mooc_provider
      if provider_connector.present?
        @got_connection = provider_connector.initialize_connection(
          current_user, email: params[:email], password: params[:password])
        provider_connector.load_user_data([current_user])
      end
    end
    set_provider_logos
    prepare_mooc_provider_settings
    @partial = render_to_string partial: 'users/mooc_provider_settings', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :set_mooc_provider_connection_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def revoke_mooc_provider_connection
    @revoked_connection = true
    mooc_provider = MoocProvider.find_by_id(params[:mooc_provider])
    if mooc_provider.present?
      provider_connector = get_connector_by_mooc_provider mooc_provider
      if provider_connector.present?
        @revoked_connection = provider_connector.destroy_connection(current_user)
      end
    end
    set_provider_logos
    prepare_mooc_provider_settings
    @partial = render_to_string partial: 'users/mooc_provider_settings', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :revoke_mooc_provider_connection_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def change_email
    message = 'Erfolgreich aktualisiert'
    @user = current_user

    # update existing emails
    @user.emails.each do |email|
      if params[:user][:user_email][:"address_#{email.id}"] != email.address
        email.address = params[:user][:user_email][:"address_#{email.id}"]
        email.save
      end
    end

    # create new emails
    total_number_of_emails = params[:user][:index].to_i
    number_of_new_emails = total_number_of_emails - @user.emails.length

    number_of_new_emails.times do |index|
      index_of_new_email = total_number_of_emails - index
      if  params[:user][:user_email][:"address_#{index_of_new_email}"].present?
        new_address = params[:user][:user_email][:"address_#{index_of_new_email}"]
        new_email = UserEmail.new({address: new_address, is_primary: false})
        new_email.user = @user
        @user.emails.push new_email
      end
    end


    # change primary state
    if params[:user][:user_email][:is_primary].include? 'new_email_index'
      splitted_string = params[:user][:user_email][:is_primary].split('_')
      new_primary_email_address = params[:user][:user_email][:"address_#{splitted_string[3]}"]
      UserEmail.find_by(address: new_primary_email_address).change_to_primary_email
    elsif params[:user][:user_email][:is_primary] != UserEmail.find_by(address: @user.primary_email).id
      UserEmail.find(params[:user][:user_email][:is_primary]).change_to_primary_email
    end

    # delete marked emails
    if session[:deleted_user_emails].present?
      session[:deleted_user_emails].each do |user_email_id|
        user_email = UserEmail.find(user_email_id)
        if user_email.is_primary == false
        user_email.destroy
        else
          message = 'Eine primäre Emailadresse kann nicht gelöscht werden.'
        end
      end
      session[:deleted_user_emails] = []
    end


    redirect_to :back, notice: message
  end

  def cancel_change_email
    session[:deleted_user_emails] = []
    redirect_to "#{user_settings_path(current_user)}?subsite=account"
  end

  private

  def prepare_mooc_provider_settings
    @mooc_providers = MoocProvider.all.map do |mooc_provider|
      provider_connector = get_connector_by_mooc_provider mooc_provider
      if provider_connector.present? && mooc_provider.api_support_state == 'oauth'
        oauth_link = provider_connector.oauth_link("#{user_settings_path(current_user)}?subsite=mooc_provider", masked_authenticity_token(session))
      end
      {id: mooc_provider.id,
       logo_id: mooc_provider.logo_id,
       api_support_state: mooc_provider.api_support_state,
       oauth_link: oauth_link}
    end
    @mooc_provider_connections = current_user.mooc_providers.pluck(:mooc_provider_id)
  end

  def set_provider_logos
    @provider_logos = AmazonS3.instance.all_provider_logos_hash
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :primary_email, :title, :password, :profile_image, :about_me)
  end
end
