require 'icalendar'

class UserDatesController < ApplicationController
  skip_before_action :require_login, only: [:my_dates]

  # GET /user_dates
  # GET /user_dates.json
  def index
    UserDate.generate_token_for_user current_user
    @user_dates = current_user.dates.sort_by(&:date)
  end

  def events_for_calendar_view
    start_param = params[:start].to_datetime
    end_param = params[:end].to_datetime
    @current_user_dates = UserDate.where('date >= ? AND date <= ? AND user_id = ?', start_param, end_param, current_user.id)
    respond_to do |format|
      format.html
      format.json { render :events_for_calendar_view, status: :ok }
    end
  end

  def synchronize_dates_on_dashboard
    @synchronization_state = UserDate.synchronize current_user
    @current_dates_to_show = current_user.dates.where('date >= ?', Date.today).sort_by(&:date).first(3)
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

  def create_calendar_feed
    respond_to do |format|
      format.html
      format.ics do
        calendar = UserDate.create_current_calendar current_user
        calendar.publish
        render text: calendar.to_ical
      end
    end
  end

  def my_dates
    user = User.find_by(token_for_user_dates: params[:token])

    respond_to do |format|
      format.html
      format.ics do
        if user.blank?
          render text: 'Not Found', status: '404'
        else
          calendar = UserDate.create_current_calendar user
          calendar.publish
          render text: calendar.to_ical
        end
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_date_params
    params.require(:user_date).permit(:user_id, :course_id, :mooc_provider_id, :date, :title, :kind, :relevant, :ressource_id_from_provider)
  end
end
