require "rails_helper"

RSpec.describe ApprovalsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/approvals").to route_to("approvals#index")
    end

    it "routes to #new" do
      expect(:get => "/approvals/new").to route_to("approvals#new")
    end

    it "routes to #show" do
      expect(:get => "/approvals/1").to route_to("approvals#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/approvals/1/edit").to route_to("approvals#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/approvals").to route_to("approvals#create")
    end

    it "routes to #update" do
      expect(:put => "/approvals/1").to route_to("approvals#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/approvals/1").to route_to("approvals#destroy", :id => "1")
    end

  end
end
