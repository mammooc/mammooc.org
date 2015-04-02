require 'rest_client'

class ApiConnectionController < ApplicationController
  def index

  end

  def send_request
    #OpenHPICourseWorker.perform_async
    #OpenSAPCourseWorker.perform_async
    EdxCourseWorker.perform_async
    redirect_to api_connection_index_path
  end

end
