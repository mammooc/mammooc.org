# frozen_string_literal: true

class UsersController < ApplicationController
  include ConnectorMapper
  before_action :set_provider_logos, only: [:settings, :mooc_provider_settings]
  load_and_authorize_resource only: [:show, :edit, :update, :destroy, :finish_signup, :completions]

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
    @user_picture = @user.profile_image.expiring_url(3600, :square)
    @bookmarks = @user.bookmarks
    @enrollments = @user.courses
    @enrollments_visible = @user.course_enrollments_visible_for_user(current_user)
    @completions_visible = @user.course_results_visible_for_user(current_user)
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: t('flash.notice.users.successfully_updated') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :settings }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    unless UserGroup.find_by(user_id: @user.id).blank?
      UserGroup.find_by(user_id: @user.id).destroy
    end
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: t('flash.notice.users.successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  def synchronize_courses
    @synchronization_state = {}
    @synchronization_state[:openHPI] = OpenHPIUserWorker.new.perform [current_user.id]
    @synchronization_state[:openSAP] = OpenSAPUserWorker.new.perform [current_user.id]
    @synchronization_state[:coursera] = if CourseraUserWorker.new.perform [current_user.id]
                                          true
                                        else
                                          CourseraConnector.new.oauth_link(synchronize_courses_path(current_user), masked_authenticity_token(session))
                                        end
    @partial = render_to_string partial: 'dashboard/user_courses', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :synchronization_result_enrollments, status: :ok }
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

  def privacy_settings
    prepare_privacy_settings
    @partial = render_to_string partial: 'users/privacy_settings', formats: [:html]

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

  def newsletter_settings
    prepare_newsletter_settings
    @partial = render_to_string partial: 'users/newsletter_settings', formats: [:html]

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

  def change_newsletter_settings
    current_user.newsletter_interval = params[:user][:newsletter_interval]
    current_user.unsubscribed_newsletter = if params[:user][:newsletter_interval].blank?
                                             true
                                           else
                                             false
                                           end
    current_user.newsletter_language = params[:user][:newsletter_language]
    current_user.save
    redirect_to "#{user_settings_path(current_user)}?subsite=newsletter", notice: t('users.settings.success')
  end

  def unsubscribe_newsletter
    current_user.unsubscribed_newsletter = true
    current_user.save
    redirect_back(fallback_location: "#{user_settings_path(current_user)}?subsite=newsletter")
  end

  def login_and_subscribe_to_newsletter
    if current_user.blank?
      flash[:error] = t('flash.error.login.required')
      session[:user_original_url] = '/users/login_and_subscribe_to_newsletter'
      redirect_to new_user_session_path
    else
      redirect_to "#{user_settings_path(current_user)}?subsite=newsletter"
    end
  end

  def settings
    prepare_mooc_provider_settings
    prepare_privacy_settings
    prepare_newsletter_settings
    @subsite = params['subsite']
    @user = current_user
    @emails = @user.emails.sort_by do |email|
      [email.is_primary ? 0 : 1, email.address]
    end
    session.delete(:deleted_user_emails)
  end

  def set_setting
    setting = current_user.setting(params[:setting], true)
    setting.set(params[:key], params[:value])

    respond_to do |format|
      format.json { render json: {status: :ok} }
    end
  end

  def connected_users_autocomplete
    search = params[:q].downcase
    users = current_user.connected_users.select {|u| u.first_name.downcase.include?(search) || u.last_name.downcase.include?(search) }
                        .collect {|u| {id: u.id, first_name: u.first_name, last_name: u.last_name} }

    respond_to do |format|
      format.json { render json: users }
    end
  end

  def oauth_callback
    code = params[:code]
    state = params[:state].split(/~/) if params[:state].present?
    mooc_provider = MoocProvider.find_by(name: state.first) if state.present?
    destination_path = state.second if state.present?
    csrf_token = state.third if state.present?
    flash['error'] ||= []

    begin
      root_uri = URI(Settings.root_url)
      destination_uri = destination_path.present? ? URI(destination_path) : URI(dashboard_path)
      destination_uri.scheme = root_uri.scheme
      destination_uri.host = root_uri.host
      destination_uri.port = root_uri.port
      destination_url = destination_uri.to_s
    rescue URI::ERROR => e
      Rails.logger.error "#{e.class}: #{e.message}"
      destination_url = dashboard_url
    end

    return oauth_error_and_redirect(destination_url) if mooc_provider.blank?

    provider_connector = get_connector_by_mooc_provider mooc_provider

    return oauth_error_and_redirect(destination_url) if provider_connector.blank? && mooc_provider.api_support_state != 'oauth'

    if code.present? && params[:error].blank? && valid_authenticity_token?(session, csrf_token)
      result = provider_connector.initialize_connection(current_user, code: code)
      redirect_to destination_url if result
      return
    end
    provider_connector.destroy_connection(current_user)
    oauth_error_and_redirect(destination_url)
  end

  def oauth_error_and_redirect(destination_path)
    flash['error'] << t('users.synchronization.oauth_error')
    destination_path.present? ? destination_path : destination_path = dashboard_path
    redirect_to destination_path
  end

  def set_mooc_provider_connection
    @got_connection = false
    mooc_provider = MoocProvider.find_by(id: params[:mooc_provider])
    if mooc_provider.present?
      provider_connector = get_connector_by_mooc_provider mooc_provider
      if provider_connector.present?
        @got_connection = provider_connector.initialize_connection(
          current_user, email: params[:email], password: params[:password]
        )
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
    mooc_provider = MoocProvider.find_by(id: params[:mooc_provider])
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
      next unless params[:user][:user_email][:"address_#{index_of_new_email}"].present?
      new_address = params[:user][:user_email][:"address_#{index_of_new_email}"]
      new_email = UserEmail.new(address: new_address, is_primary: false)
      new_email.user = @user
      @user.emails.push new_email
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
        user_email.destroy
      end
      session.delete(:deleted_user_emails)
    end

    redirect_to "#{user_settings_path(current_user)}?subsite=account", notice: t('users.settings.change_emails.success')
  end

  def cancel_change_email
    session.delete(:deleted_user_emails)
    redirect_to "#{user_settings_path(current_user)}?subsite=account"
  end

  def completions
    @completions = Completion.where(user: @user).sort_by(&:created_at).reverse
    courses = []
    @completions.each do |completion|
      courses.push(completion.course)
    end
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(courses)
    @number_of_certificates = []
    @completions.each do |completion|
      @number_of_certificates.push completion.certificates.count
    end
    @verify_available = []
    @completions.each do |completion|
      @verify_available.push completion.certificates.pluck(:verification_url).reject(&:blank?).present? ? true : false
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
       url: mooc_provider.url,
       logo_id: mooc_provider.logo_id,
       api_support_state: mooc_provider.api_support_state,
       oauth_link: oauth_link}
    end
    @mooc_provider_connections = current_user.mooc_providers.pluck(:mooc_provider_id)
  end

  def prepare_privacy_settings
    @course_enrollments_visibility_groups = Group.find(current_user.setting(:course_enrollments_visibility, true).value(:groups) || [])
    @course_enrollments_visibility_users = User.find(current_user.setting(:course_enrollments_visibility, true).value(:users) || [])

    @course_results_visibility_groups = Group.find(current_user.setting(:course_results_visibility, true).value(:groups) || [])
    @course_results_visibility_users = User.find(current_user.setting(:course_results_visibility, true).value(:users) || [])

    @course_progress_visibility_groups = Group.find(current_user.setting(:course_progress_visibility, true).value(:groups) || [])
    @course_progress_visibility_users = User.find(current_user.setting(:course_progress_visibility, true).value(:users) || [])

    @profile_visibility_groups = Group.find(current_user.setting(:profile_visibility, true).value(:groups) || [])
    @profile_visibility_users = User.find(current_user.setting(:profile_visibility, true).value(:users) || [])
  end

  def prepare_newsletter_settings
    @user = current_user
    @newsletter_interval = current_user.newsletter_interval
    @interval_options = [[I18n.t('users.settings.newsletter.interval.daily'), '1'],
                         [I18n.t('users.settings.newsletter.interval.week'), '7'],
                         [I18n.t('users.settings.newsletter.interval.two_weeks'), '14'],
                         [I18n.t('users.settings.newsletter.interval.month'), '30']]
    @available_languages = []
    I18n.available_locales.each do |locale|
      @available_languages.push [I18n.t('locale_name', locale: locale), locale.to_s]
    end
  end

  def set_provider_logos
    @provider_logos = AmazonS3.instance.all_provider_logos_hash
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :primary_email, :title, :password, :profile_image, :about_me)
  end
end
