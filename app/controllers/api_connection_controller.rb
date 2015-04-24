class ApiConnectionController < ApplicationController

  def index

  end

  def send_request
    OpenHPICourseWorker.perform_async
    OpenSAPCourseWorker.perform_async
    EdxCourseWorker.perform_async
    CourseraCourseWorker.perform_async
    redirect_to api_connection_index_path
  end

  def send_user_request
    OpenSAPConnector.new.initialize_connection(current_user, {email: params[:email], password: params[:password]})
    OpenHPIConnector.new.initialize_connection(current_user, {email: params[:email], password: params[:password]})
    redirect_to api_connection_index_path
  end

  def synchronize_courses_for_user
    OpenHPIUserWorker.new.perform [current_user.id]
    OpenSAPUserWorker.new.perform [current_user.id]
    @partial = render_to_string partial: 'dashboard/user_courses', formats: [:html]
    puts @partial
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

  def update_user
    OpenSAPConnector.new.load_user_data([current_user])
    redirect_to api_connection_index_path
  end

  def update_all_users
    OpenHPIUserWorker.perform_async
    redirect_to api_connection_index_path
  end

end
