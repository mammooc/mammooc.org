require 'rails_helper'

RSpec.describe "Approvals", :type => :request do
  describe "GET /approvals" do
    it "works! (now write some real specs)" do
      get approvals_path
      expect(response).to have_http_status(200)
    end
  end
end
