require "rails_helper"

RSpec.describe RecommendationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/recommendations").to route_to("recommendations#index")
    end

    it "routes to #new" do
      expect(:get => "/recommendations/new").to route_to("recommendations#new")
    end

    it "routes to #show" do
      expect(:get => "/recommendations/1").to route_to("recommendations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/recommendations/1/edit").to route_to("recommendations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/recommendations").to route_to("recommendations#create")
    end

    it "routes to #update" do
      expect(:put => "/recommendations/1").to route_to("recommendations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/recommendations/1").to route_to("recommendations#destroy", :id => "1")
    end

  end
end
