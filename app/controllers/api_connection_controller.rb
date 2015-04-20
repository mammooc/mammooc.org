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
    redirect_to api_connection_index_path
  end

  def update_user
    OpenSAPConnector.new.load_user_data([current_user])
    redirect_to api_connection_index_path
  end

  def update_all_users
    OpenHPIUserWorker.perform_async nil
    redirect_to api_connection_index_path
  end

end
