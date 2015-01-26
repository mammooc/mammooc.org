require 'rails_helper'

RSpec.describe DashboardController, :type => :controller do

  describe "GET dashboard" do
    it "returns http success" do
      get :dashboard
      expect(response).to have_http_status(:success)
    end
  end

end
