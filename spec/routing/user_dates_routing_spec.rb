require "rails_helper"

RSpec.describe UserDatesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/user_dates").to route_to("user_dates#index")
    end

    it "routes to #new" do
      expect(:get => "/user_dates/new").to route_to("user_dates#new")
    end

    it "routes to #show" do
      expect(:get => "/user_dates/1").to route_to("user_dates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/user_dates/1/edit").to route_to("user_dates#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/user_dates").to route_to("user_dates#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/user_dates/1").to route_to("user_dates#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/user_dates/1").to route_to("user_dates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/user_dates/1").to route_to("user_dates#destroy", :id => "1")
    end

  end
end
