require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do

  describe "GET #delete_group_newsfeed_entry" do
    it "returns http success" do
      get :delete_group_newsfeed_entry
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #delete_user_from_newsfeed_entry" do
    it "returns http success" do
      get :delete_user_from_newsfeed_entry
      expect(response).to have_http_status(:success)
    end
  end

end
