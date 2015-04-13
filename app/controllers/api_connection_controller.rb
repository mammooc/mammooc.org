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
    requestParameters = "email=" + params[:email] + "&password=" + params[:password]
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
    mooc_provider = MoocProvider.find_by_name("openHPI").id
    authentication_token = MoocProviderUser.where(user_id: current_user, mooc_provider_id: mooc_provider).first.authentication_token
    token_string = "Token token=#{authentication_token}"

    response = RestClient.get("https://open.hpi.de/api/users/me/enrollments", {:accept => 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', :authorization => token_string})
    json_response = JSON.parse response

    json_response.each {|enrollment|
      course = Course.where(mooc_provider_id: mooc_provider, provider_course_id: enrollment['course_id']).first
      current_user.courses << course
    }

    redirect_to api_connection_index_path
  end

end
