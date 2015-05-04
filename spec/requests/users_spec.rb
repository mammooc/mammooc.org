require 'rails_helper'

RSpec.describe "Users", :type => :request do

  before(:each) do
    sign_in_as_a_valid_user
  end

  describe "GET /users" do
    it "is not authorized" do
      get users_path
      expect(response).to have_http_status(302)
    end
  end
end
