require "rails_helper"

RSpec.describe MoocProvidersController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/mooc_providers").to route_to("mooc_providers#index")
    end

    it "routes to #new" do
      expect(:get => "/mooc_providers/new").to route_to("mooc_providers#new")
    end

    it "routes to #show" do
      expect(:get => "/mooc_providers/1").to route_to("mooc_providers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/mooc_providers/1/edit").to route_to("mooc_providers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/mooc_providers").to route_to("mooc_providers#create")
    end

    it "routes to #update" do
      expect(:put => "/mooc_providers/1").to route_to("mooc_providers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/mooc_providers/1").to route_to("mooc_providers#destroy", :id => "1")
    end

  end
end
