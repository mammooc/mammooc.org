class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy, :admins, :invite_group_members]

  # GET /groups
  # GET /groups.json
  def index
    @groups = current_user.groups
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    admins
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
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
        format.html { redirect_to @group, notice: t('group_success_create') }
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
        format.html { redirect_to @group, notice: t('group_success_update') }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def invite_group_members
    invite_members
    format.html { redirect_to @group, notice: t('group_success_update') }
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: t('group_success_destroy') }
      format.json { head :no_content }
    end
  end

  def admins
    admin_ids = UserGroup.where(group_id: @group.id, is_admin: true).collect{|user_groups| user_groups.user_id}
    @admins = Array.new
    admin_ids.each do |admin_id|
      @admins.push(User.find(admin_id))
    end
    return @admins
  end

  def join
    group_invitation = GroupInvitation.find_by_token!(params[:token])

    if group_invitation.expiry_date <= Time.now.in_time_zone
      flash[:error] = t('link_expired')
      redirect_to root_path
      return
    end

    if group_invitation.used == true
      flash[:error] = t('link_used')
      redirect_to root_path
      return
    end

    if group_invitation.group_id.nil?
      flash[:error] = t('group_deleted')
      redirect_to root_path
      return
    end

    group = Group.find(group_invitation.group_id)
    if group.users.include? current_user
      flash[:notice] = t('already_member')
    else
      group.users.push(current_user)
      flash[:success] = t('joined_group')
    end

    group_invitation.used = true
    group_invitation.save

    redirect_to group_path(group)


  rescue ActiveRecord::RecordNotFound => error
    flash[:error] = t('link_invalid')
    redirect_to root_path

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :imageId, :description, :primary_statistics)
    end

    def invited_members
      params[:members]
    end

    def invite_members
      return if invited_members.blank?
      emails = invited_members.split(/[^[:alpha:]]\s+|\s+|;\s*|,\s*/)
      expiry_date = Settings.token_expiry_date
      emails.each do |email_address|
        token = SecureRandom.urlsafe_base64(Settings.token_length)
        until GroupInvitation.find_by_token(token).nil? do
          token = SecureRandom.urlsafe_base64(Settings.token_length)
        end
        link = root_url + 'groups/join/' + token
        GroupInvitation.create(token: token, group_id: @group.id, expiry_date: expiry_date)
        UserMailer.group_invitation_mail(email_address, link, @group, current_user, root_url).deliver_later
      end

    end

end
