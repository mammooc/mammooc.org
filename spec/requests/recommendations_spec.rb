require 'rails_helper'

RSpec.describe "Recommendations", :type => :request do
  describe "GET /recommendations" do
    it "works! (now write some real specs)" do
      get recommendations_path
      expect(response).to have_http_status(200)
    end
  end
end
