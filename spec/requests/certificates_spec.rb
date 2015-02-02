require 'rails_helper'

RSpec.describe "Certificates", :type => :request do

  before(:each) do
    sign_in_as_a_valid_user
  end

  describe "GET /certificates" do
    it "works! (now write some real specs)" do
      get certificates_path
      expect(response).to have_http_status(200)
    end
  end
end
