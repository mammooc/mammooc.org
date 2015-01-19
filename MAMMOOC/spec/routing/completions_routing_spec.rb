require "rails_helper"

RSpec.describe CompletionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/completions").to route_to("completions#index")
    end

    it "routes to #new" do
      expect(:get => "/completions/new").to route_to("completions#new")
    end

    it "routes to #show" do
      expect(:get => "/completions/1").to route_to("completions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/completions/1/edit").to route_to("completions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/completions").to route_to("completions#create")
    end

    it "routes to #update" do
      expect(:put => "/completions/1").to route_to("completions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/completions/1").to route_to("completions#destroy", :id => "1")
    end

  end
end
