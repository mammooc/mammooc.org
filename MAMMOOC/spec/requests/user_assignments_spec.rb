require 'rails_helper'

RSpec.describe "UserAssignments", :type => :request do
  describe "GET /user_assignments" do
    it "works! (now write some real specs)" do
      get user_assignments_path
      expect(response).to have_http_status(200)
    end
  end
end
