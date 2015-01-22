require "rails_helper"

RSpec.describe CourseAssignmentsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/course_assignments").to route_to("course_assignments#index")
    end

    it "routes to #new" do
      expect(:get => "/course_assignments/new").to route_to("course_assignments#new")
    end

    it "routes to #show" do
      expect(:get => "/course_assignments/1").to route_to("course_assignments#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/course_assignments/1/edit").to route_to("course_assignments#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/course_assignments").to route_to("course_assignments#create")
    end

    it "routes to #update" do
      expect(:put => "/course_assignments/1").to route_to("course_assignments#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/course_assignments/1").to route_to("course_assignments#destroy", :id => "1")
    end

  end
end
