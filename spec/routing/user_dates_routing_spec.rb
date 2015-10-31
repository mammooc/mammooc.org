require "rails_helper"

RSpec.describe UserDatesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/user_dates").to route_to("user_dates#index")
    end

  end
end
