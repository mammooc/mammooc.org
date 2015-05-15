# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  include ConnectorMapper
  before_action :set_provider_logos, only: [:settings, :mooc_provider_settings]
  load_and_authorize_resource only: [:show, :edit, :update, :destroy]

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
  end

  # GET /users/1/edit
  def edit
  end


  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    # authorize! :update, @user
    if request.patch? && params[:user] #&& params[:user][:email]
      if @user.update(user_params)
        @user.skip_reconfirmation!
        sign_in(@user, :bypass => true)
        redirect_to @user, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
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
    @partial = render_to_string partial: 'devise/registrations/edit', formats: [:html]
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
    prepare_mooc_provider_settings
    @subsite = params['subsite']
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
    params.require(:user).permit(:first_name, :last_name, :title, :password, :profile_image_id, :about_me) #:email_settings,
  end
end
