require "rails_helper"

RSpec.describe CoursesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/courses").to route_to("courses#index")
    end

    it "routes to #show" do
      expect(:get => "/courses/1").to route_to("courses#show", :id => "1")
    end

  end
end
