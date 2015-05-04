class GroupsController < ApplicationController
  load_and_authorize_resource only: [:index, :show, :edit, :update, :destroy, :admins, :invite_group_members, :add_administrator, :members, :recommendations, :statistics, :demote_administrator, :remove_group_member, :leave, :condition_for_changing_member_status, :all_members_to_administrators, :recommendations, :synchronize_courses]
  
  NUMBER_OF_SHOWN_RECOMMENDATIONS = 2
  NUMBER_OF_SHOWN_USERS = 10

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to groups_path, alert: t("unauthorized.#{exception.action}.group") }
      format.json do
        error = {message: exception.message, action: exception.action, subject: exception.subject.id}
        render json: error.to_json, status: :unauthorized
      end
    end
  end

  # GET /groups
  # GET /groups.json
  def index
    @groups = current_user.groups
    @groups_pictures = AmazonS3.instance.get_group_images_hash_for_groups @groups
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @ordered_group_members = sort_by_name(admins) + sort_by_name(@group.users - admins)
    @group_users = (@group.users - admins).size > NUMBER_OF_SHOWN_USERS ? (@group.users - admins).shuffle : sort_by_name(@group.users - admins)
    @group_admins = admins.size > NUMBER_OF_SHOWN_USERS ? sort_by_name(admins) : admins.shuffle

    # RECOMMENDATIONS
    sorted_recommendations = @group.recommendations.sort_by { |recommendation| recommendation.created_at}.reverse!
    @recommendations = sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = sorted_recommendations.length
    @provider_logos = AmazonS3.instance.get_provider_logos_hash_for_recommendations(@recommendations)

    @profile_pictures = AmazonS3.instance.get_author_profile_images_hash_for_recommendations(@recommendations)
    @profile_pictures = AmazonS3.instance.get_user_profile_images_hash_for_users(@group.users, @profile_pictures)

    @group_picture = AmazonS3.instance.get_group_images_hash_for_groups [@group]
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  def recommendations
    @recommendations = @group.recommendations.sort_by { |recommendation| recommendation.created_at}.reverse!
    @provider_logos = AmazonS3.instance.get_provider_logos_hash_for_recommendations(@recommendations)
    @profile_pictures = AmazonS3.instance.get_author_profile_images_hash_for_recommendations(@recommendations)
    @group_picture = AmazonS3.instance.get_group_images_hash_for_groups [@group]
  end

  def members
    @sorted_group_users = sort_by_name(@group.users - admins)
    @sorted_group_admins = sort_by_name(admins)
    @group_members = @group.users - [current_user]
    @profile_pictures = AmazonS3.instance.get_user_profile_images_hash_for_users(@group.users)
    @group_picture = AmazonS3.instance.get_group_images_hash_for_groups [@group]
  end

  def statistics
    @group_picture = AmazonS3.instance.get_group_images_hash_for_groups [@group]
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    @group.image_id = 'group_picture_default.png'
    respond_to do |format|
      if @group.save
        @group.users.push(current_user)
        UserGroup.set_is_admin(@group.id, current_user.id, true)
        invite_members
        format.html { redirect_to @group, notice: t('flash.notice.groups.successfully_created') }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        invite_members
        format.html { redirect_to @group, notice: t('flash.notice.groups.successfully_updated') }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def invite_group_members
    respond_to do |format|
      begin
        invite_members
        format.html { redirect_to @group, notice: t('flash.notice.groups.successfully_updated') }
        format.json { render :invite_members_result, status: :created, location: @group }
      rescue StandardError => e
        format.html { redirect_to @group, notice: t('flash.error.groups.update') }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def add_administrator
    respond_to do |format|
      begin
        add_admin
        format.html { redirect_to @group, notice: t('flash.notice.groups.successfully_updated') }
        format.json { render :show, status: :created, location: @group }
      rescue StandardError => e
        format.html { redirect_to @group, notice: t('flash.error.groups.update') }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def demote_administrator
    respond_to do |format|
      begin
        demote_admin
        format.html { redirect_to @group, notice: t('flash.notice.groups.successfully_updated') }
        format.json { render :demoted_administrator, status: :ok, location: @group }
      rescue StandardError => e
        format.html { redirect_to @group, notice: t('flash.error.groups.update') }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def remove_group_member
    respond_to do |format|
      begin
        remove_member removing_member
        format.html { redirect_to @group, notice: t('flash.notice.groups.successfully_updated') }
        format.json { render :show, status: :created, location: @group }
      rescue StandardError => e
        format.html { redirect_to @group, notice: t('flash.error.groups.update') }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def leave
    respond_to do |format|
      begin
        remove_member current_user.id
        format.html { redirect_to @group, notice: t('flash.notice.groups.successfully_updated') }
        format.json { render :show, status: :created, location: @group }
      rescue StandardError => e
        format.html { redirect_to @group, notice: t('flash.error.groups.update') }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def condition_for_changing_member_status
    respond_to do |format|
      begin
        condition_for_changing_member
        format.html { redirect_to @group, notice: t('flash.notice.groups.successfully_updated') }
        format.json { render :condition_for_changing_member_status, status: :created, location: @group }
      rescue StandardError => e
        format.html { redirect_to @group, notice: t('flash.error.groups.update') }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def all_members_to_administrators
    respond_to do |format|
      begin
        all_members_to_admins
        format.html { redirect_to @group, notice: t('flash.notice.groups.successfully_updated') }
        format.json { render :show, status: :created, location: @group }
      rescue StandardError => e
        format.html { redirect_to @group, notice: t('flash.error.groups.update') }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def synchronize_courses
    OpenHPIUserWorker.perform_async @group.users.pluck(:id)
    OpenSAPUserWorker.perform_async @group.users.pluck(:id)
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

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: t('flash.notice.groups.successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  def admins
    admin_ids = UserGroup.where(group_id: @group.id, is_admin: true).collect{|user_groups| user_groups.user_id}
    admins = Array.new
    admin_ids.each do |admin_id|
      admins.push(User.find(admin_id))
    end
    return admins
  end

  def join
    group_invitation = GroupInvitation.find_by_token!(params[:token])

    if group_invitation.expiry_date <= Time.now.in_time_zone
      flash[:error] = t('groups.invitation.link_expired')
      redirect_to root_path
      return
    end

    if group_invitation.used == true
      flash[:error] = t('groups.invitation.link_used')
      redirect_to root_path
      return
    end

    if group_invitation.group_id.nil?
      flash[:error] = t('groups.invitation.group_deleted')
      redirect_to root_path
      return
    end

    group = Group.find(group_invitation.group_id)
    if group.users.include? current_user
      flash[:notice] = t('groups.invitation.already_member')
    else
      group.users.push(current_user)
      flash[:success] = t('groups.invitation.joined_group')
    end

    group_invitation.used = true
    group_invitation.save

    redirect_to group_path(group)


  rescue ActiveRecord::RecordNotFound => error
    flash[:error] = t('groups.invitation.link_invalid')
    redirect_to root_path

  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :image_id, :description, :primary_statistics)
    end

    def invited_members
      params[:members]
    end

    def additional_admin
      params[:additional_administrator]
    end

    def demoted_admin
      params[:demoted_admin]
    end

    def removing_member
      params[:removing_member]
    end

    def changing_member
      params[:changing_member]
    end

    LCHARS    = /\w+\p{L}\p{N}\-\!\/#\$%&'*+=?^`{|}~/
    LOCAL     = /[#{LCHARS.source}]+(\.[#{LCHARS.source}]+)*/
    DCHARS    = /A-z\d/
    SUBDOMAIN = /[#{DCHARS.source}]+(\-+[#{DCHARS.source}]+)*/
    DOMAIN    = /#{SUBDOMAIN.source}(\.#{SUBDOMAIN.source})*\.[#{DCHARS.source}]{2,}/
    EMAIL     = /\A#{LOCAL.source}@#{DOMAIN.source}\z/i

    def invite_members
      @error_emails ||= []
      return if invited_members.blank?
      emails = invited_members.split(/[^[:alpha:]]\s+|\s+|;\s*|,\s*/)
      expiry_date = Settings.token_expiry_date
      emails.each do |email_address|
        if email_address == EMAIL.match(email_address).to_s
          token = SecureRandom.urlsafe_base64(Settings.token_length)
          until GroupInvitation.find_by_token(token).nil? do
            token = SecureRandom.urlsafe_base64(Settings.token_length)
          end
          link = root_url + 'groups/join/' + token
          GroupInvitation.create(token: token, group_id: @group.id, expiry_date: expiry_date)
          UserMailer.group_invitation_mail(email_address, link, @group, current_user, root_url).deliver_later
        else
          @error_emails << email_address
        end
      end
    end

    def add_admin
      UserGroup.set_is_admin(@group.id, additional_admin, true)
    end

    def all_members_to_admins
      @group.users.each do |user|
        UserGroup.set_is_admin(@group.id, user.id, true)
      end
    end

    def demote_admin
      UserGroup.set_is_admin(@group.id, demoted_admin, false)
      if User.find(demoted_admin) == current_user
        @status = 'demote myself'
      else
        @status = 'demote another member'
      end
    end

    def remove_member member_id
      UserGroup.find_by(group_id: @group.id, user_id: member_id).destroy
    end

    def condition_for_changing_member
      if @group.users.count == 1
        @status = 'last_member'
      elsif admins.count == 1 && admins.include?(User.find(changing_member))
        @status = 'last_admin'
      else
        @status = 'ok'
      end
    end

    def sort_by_name members
      members.sort_by{ |m| [m.last_name, m.first_name] }
    end
end
