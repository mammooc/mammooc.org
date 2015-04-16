require 'rest_client'

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
    requestParameters = "email=#{params[:email]}&password=#{params[:password]}"
    response = RestClient.post("https://open.hpi.de/api/authenticate", requestParameters, {:accept => 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', :authorization => 'token=\"78783786789\"'})
    json_response = JSON.parse response

    connection = MoocProviderUser.new
    connection.authentication_token = json_response['token']
    connection.user_id = current_user.id
    connection.mooc_provider_id = MoocProvider.find_by_name("openHPI").id
    connection.save

    redirect_to api_connection_index_path
  end

  def update_user
    OpenHPIUserWorker.perform_async([current_user.id])

    redirect_to api_connection_index_path
  end

  def update_all_users
    OpenHPIUserWorker.perform_async nil

    redirect_to api_connection_index_path
  end

end
