require 'rest_client'

class ApiConnectionController < ApplicationController
  def index

  end

  def sendRequest
    OpenHPICourseWorker.perform_async
    redirect_to api_connection_index_path
  end

end
