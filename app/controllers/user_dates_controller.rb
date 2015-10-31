require 'icalendar'

class UserDatesController < ApplicationController
  before_action :set_user_date, only: [:show, :edit, :update, :destroy]
  skip_before_action :require_login, only: [:calendar_feed]

  # GET /user_dates
  # GET /user_dates.json
  def index
    @user_dates = current_user.dates.sort_by(&:date)
  end

  def synchronize_dates_on_dashboard
    @synchronization_state = UserDate.synchronize current_user
    @partial = render_to_string partial: 'dashboard/user_dates', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :synchronization_result_user_dates, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def synchronize_dates_on_index_page
    @synchronization_state = UserDate.synchronize current_user
    @partial = render_to_string partial: 'my_dates', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to user_dates_path }
        format.json { render :synchronization_result_user_dates, status: :ok }
      rescue StandardError => e
        format.html { redirect_to user_dates_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def calendar_feed

    respond_to do |format|
      format.html
      format.ics do
        calendar = UserDate.create_current_calendar current_user
        calendar.publish
        render :text => calendar.to_ical
      end
    end
  end


  # GET /user_dates/1
  # GET /user_dates/1.json
  def show
  end

  # GET /user_dates/new
  def new
    @user_date = UserDate.new
  end

  # GET /user_dates/1/edit
  def edit
  end

  # POST /user_dates
  # POST /user_dates.json
  def create
    @user_date = UserDate.new(user_date_params)

    respond_to do |format|
      if @user_date.save
        format.html { redirect_to @user_date, notice: 'User date was successfully created.' }
        format.json { render :show, status: :created, location: @user_date }
      else
        format.html { render :new }
        format.json { render json: @user_date.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_dates/1
  # PATCH/PUT /user_dates/1.json
  def update
    respond_to do |format|
      if @user_date.update(user_date_params)
        format.html { redirect_to @user_date, notice: 'User date was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_date }
      else
        format.html { render :edit }
        format.json { render json: @user_date.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_dates/1
  # DELETE /user_dates/1.json
  def destroy
    @user_date.destroy
    respond_to do |format|
      format.html { redirect_to user_dates_url, notice: 'User date was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_date
      @user_date = UserDate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_date_params
      params.require(:user_date).permit(:user_id, :course_id, :mooc_provider_id, :date, :title, :kind, :relevant, :ressource_id_from_provider)
    end
end
