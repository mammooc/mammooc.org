require 'rails_helper'

RSpec.describe "CourseResults", :type => :request do

  before(:each) do
    sign_in_as_a_valid_user
  end

  describe "GET /course_results" do
    it "works! (now write some real specs)" do
      get course_results_path
      expect(response).to have_http_status(200)
    end
  end
end
