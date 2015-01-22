require "rails_helper"

RSpec.describe StatisticsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/statistics").to route_to("statistics#index")
    end

    it "routes to #new" do
      expect(:get => "/statistics/new").to route_to("statistics#new")
    end

    it "routes to #show" do
      expect(:get => "/statistics/1").to route_to("statistics#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/statistics/1/edit").to route_to("statistics#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/statistics").to route_to("statistics#create")
    end

    it "routes to #update" do
      expect(:put => "/statistics/1").to route_to("statistics#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/statistics/1").to route_to("statistics#destroy", :id => "1")
    end

  end
end
