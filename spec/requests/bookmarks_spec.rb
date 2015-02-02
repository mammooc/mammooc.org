require 'rails_helper'

RSpec.describe "Bookmarks", :type => :request do

  before(:each) do
    sign_in_as_a_valid_user
  end

  describe "GET /bookmarks" do
    it "works! (now write some real specs)" do
      get bookmarks_path
      expect(response).to have_http_status(200)
    end
  end
end
