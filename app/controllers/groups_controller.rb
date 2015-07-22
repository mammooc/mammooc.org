# -*- encoding : utf-8 -*-
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
    @groups = @groups.where('name LIKE ?', "%#{params[:q]}%") if params[:q].present?
    @groups = current_user.groups_sorted_by_admin_state_and_name(@groups)
    @groups_pictures = Group.group_images_hash_for_groups @groups

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @ordered_group_members = sort_by_name(admins) + sort_by_name(@group.users - admins)
    @group_users = (@group.users - admins).size > NUMBER_OF_SHOWN_USERS ? (@group.users - admins).shuffle : sort_by_name(@group.users - admins)
    @group_admins = admins.size > NUMBER_OF_SHOWN_USERS ? sort_by_name(admins) : admins.shuffle

    # RECOMMENDATIONS
    sorted_recommendations = @group.recommendations.sort_by(&:created_at).reverse!
    @recommendations = sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = sorted_recommendations.length
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_recommendations(@recommendations)

    @group_picture = Group.group_images_hash_for_groups [@group]

    # ACTIVITIES
    # rubocop:disable Style/Next
    @activities = PublicActivity::Activity.order('created_at desc').select {|activity| (@group.users.collect(&:id).include? activity.owner_id) && activity.group_ids.present? && (activity.group_ids.include? @group.id) }
    @activity_courses = {}
    @activity_courses_bookmarked = {}
    if @activities.present?
      @activities.each do |activity|
        @activity_courses[activity.id] = case activity.trackable_type
                                           when 'Recommendation' then Recommendation.find(activity.trackable_id).course
                                           when 'Course' then Course.find(activity.trackable_id)
                                           when 'Bookmark' then Bookmark.find(activity.trackable_id).course
                                         end
        if @activity_courses[activity.id].present?
          @activity_courses_bookmarked[activity.id] = @activity_courses[activity.id].bookmarked_by_user? current_user
        end
        # privacy settings
        if activity.key == 'course.enroll'
          unless activity.owner.course_enrollments_visible_for_group(@group)
            @activities -= [activity]
          end
        end
      end
    end
    # rubocop:enable Style/Next

    # PICTURES
    @profile_pictures = User.author_profile_images_hash_for_activities(@activities)
    @profile_pictures = User.user_profile_images_hash_for_users(@group.users, @profile_pictures)
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  def recommendations
    @recommendations = @group.recommendations.sort_by(&:created_at).reverse!
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_recommendations(@recommendations)
    @profile_pictures = User.author_profile_images_hash_for_recommendations(@recommendations)
    @group_picture = Group.group_images_hash_for_groups [@group]

    @activities = PublicActivity::Activity.order('created_at desc').where(owner_id: @group.users, trackable_type: 'Recommendation')
    @activity_courses = {}
    @activity_courses_bookmarked = {}
    return unless @activities
    @activities.each do |activity|
      if activity.group_ids && (activity.group_ids.include? @group.id)
        @activity_courses[activity.id] = Recommendation.find(activity.trackable_id).course
        @activity_courses_bookmarked[activity.id] = @activity_courses[activity.id].bookmarked_by_user? current_user
      else
        @activities -= [activity]
      end
    end
  end

  def members
    @sorted_group_users = sort_by_name(@group.users - admins)
    @sorted_group_admins = sort_by_name(admins)
    @group_members = @group.users - [current_user]
    @profile_pictures = User.user_profile_images_hash_for_users(@group.users)
    @group_picture = Group.group_images_hash_for_groups [@group]
  end

  def statistics
    @group_picture = Group.group_images_hash_for_groups [@group]
    @average_enrollments = @group.average_enrollments
    @enrolled_courses_with_amount = @group.enrolled_courses_with_amount
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(@group.enrolled_courses)
    @number_of_users_share_course_enrollments = @group.number_of_users_who_share_course_enrollments
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
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

  def groups_where_user_is_admin
    group_ids = UserGroup.where(user: current_user, is_admin: true).collect(&:group_id)
    @admin_groups = Group.find(group_ids).sort_by(&:name)
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
    admin_ids = UserGroup.where(group_id: @group.id, is_admin: true).collect(&:user_id)
    admins = []
    admin_ids.each do |admin_id|
      admins.push(User.find(admin_id))
    end
    admins
  end

  def join
    group_invitation = GroupInvitation.find_by_token!(params[:token])

    if group_invitation.expiry_date <= Time.zone.now.in_time_zone
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
    group.create_activity key: 'group.join', owner: current_user, group_ids: [group.id], user_ids: (group.user_ids - [current_user.id])

    redirect_to group_path(group)

  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('groups.invitation.link_invalid')
    redirect_to root_path
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:name, :image, :description, :primary_statistics)
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

  def invite_members
    @error_emails ||= []
    return if invited_members.blank?
    emails = invited_members.split(/[^[:alpha:]]\s+|\s+|;\s*|,\s*/)
    expiry_date = Settings.token_expiry_date
    emails.each do |email_address|
      if email_address == UserEmail::EMAIL.match(email_address).to_s
        token = SecureRandom.urlsafe_base64(Settings.token_length)
        until GroupInvitation.find_by_token(token).nil?
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

  def remove_member(member_id)
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

  def sort_by_name(members)
    members.sort_by {|m| [m.last_name, m.first_name] }
  end
end
