require 'rails_helper'

RSpec.describe "CourseAssignments", :type => :request do
  describe "GET /course_assignments" do
    it "works! (now write some real specs)" do
      get course_assignments_path
      expect(response).to have_http_status(200)
    end
  end
end
