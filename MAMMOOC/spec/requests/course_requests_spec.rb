require 'rails_helper'

RSpec.describe "CourseRequests", :type => :request do
  describe "GET /course_requests" do
    it "works! (now write some real specs)" do
      get course_requests_path
      expect(response).to have_http_status(200)
    end
  end
end
