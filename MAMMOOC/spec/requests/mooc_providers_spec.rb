require 'rails_helper'

RSpec.describe "MoocProviders", :type => :request do
  describe "GET /mooc_providers" do
    it "works! (now write some real specs)" do
      get mooc_providers_path
      expect(response).to have_http_status(200)
    end
  end
end
