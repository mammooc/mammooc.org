require "rails_helper"

RSpec.describe CourseRequestsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/course_requests").to route_to("course_requests#index")
    end

    it "routes to #new" do
      expect(:get => "/course_requests/new").to route_to("course_requests#new")
    end

    it "routes to #show" do
      expect(:get => "/course_requests/1").to route_to("course_requests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/course_requests/1/edit").to route_to("course_requests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/course_requests").to route_to("course_requests#create")
    end

    it "routes to #update" do
      expect(:put => "/course_requests/1").to route_to("course_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/course_requests/1").to route_to("course_requests#destroy", :id => "1")
    end

  end
end
