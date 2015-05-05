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

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
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
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def synchronize_courses
    OpenHPIUserWorker.new.perform [current_user.id]
    OpenSAPUserWorker.new.perform [current_user.id]
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
        format.json { render :synchronization_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def mooc_provider_settings
    @mooc_providers = MoocProvider.select([:id, :logo_id]).map {|e| {id: e.id, logo_id: e.logo_id} }
    @mooc_provider_connections = current_user.mooc_providers.pluck(:mooc_provider_id)

    @partial = render_to_string partial: 'users/mooc_provider_settings', formats: [:html]
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

  def settings
  end

  def set_mooc_provider_connection
    @got_connection = false
    mooc_provider = MoocProvider.find_by_id(params[:mooc_provider])
    if mooc_provider.present?
      provider_connector = get_connector_by_mooc_provider mooc_provider
      if provider_connector.present?
        @got_connection = provider_connector.initialize_connection(
          current_user, email: params[:email], password: params[:password])
      end
    end
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :rename_mooc_provider_connection_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def revoke_mooc_provider_connection
    @revoked_connection = true
    connections = MoocProviderUser.where(user_id: current_user.id, mooc_provider_id: params[:mooc_provider])
    connections.destroy_all
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

  def set_provider_logos
    @provider_logos = AmazonS3.instance.get_all_provider_logos_hash
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :title, :password, :profile_image_id, :about_me) #:email_settings,
  end
end
