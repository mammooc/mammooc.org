require 'rails_helper'

RSpec.describe "courses/index", :type => :view do
  before(:each) do
    moocProvider = MoocProvider.create()

    assign(:courses, [
      Course.create!(
        :name => "Name",
        :url => "Url",
        :course_instructors => "Course Instructor",
        :abstract => "MyText",
        :language => "Language",
        :imageId => "Image",
        :videoId => "Video",
        :duration => "Duration",
        :costs => "Costs",
        :type_of_achievement => "Type Of Achievement",
        :categories => "Categories",
        :difficulty => "Difficulty",
        :requirements => "Requirements",
        :minimum_weekly_workload => 1,
        :maximum_weekly_workload => 2,
        :provider_course_id => 1,
        :mooc_provider => nil,
        :course_result => nil,
        :start_date => DateTime.new(2015,9,3,9),
        :end_date => DateTime.new(2015,10,3,9),
        :mooc_provider_id => moocProvider.id
      ),
      Course.create!(
        :name => "Name",
        :url => "Url",
        :course_instructors => "Course Instructor",
        :abstract => "MyText",
        :language => "Language",
        :imageId => "Image",
        :videoId => "Video",
        :duration => "Duration",
        :costs => "Costs",
        :type_of_achievement => "Type Of Achievement",
        :categories => "Categories",
        :difficulty => "Difficulty",
        :requirements => "Requirements",
        :minimum_weekly_workload => 1,
        :maximum_weekly_workload => 2,
        :provider_course_id => 1,
        :mooc_provider => nil,
        :course_result => nil,
        :start_date => DateTime.new(2015,9,3,9),
        :end_date => DateTime.new(2015,10,3,9),
        :mooc_provider_id => moocProvider.id
      )
    ])
  end

  it "renders a list of courses" do
    pending
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => "Course Instructor".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Language".to_s, :count => 2
    assert_select "tr>td", :text => "Image".to_s, :count => 2
    assert_select "tr>td", :text => "Video".to_s, :count => 2
    assert_select "tr>td", :text => "Duration".to_s, :count => 2
    assert_select "tr>td", :text => "Costs".to_s, :count => 2
    assert_select "tr>td", :text => "Type Of Achievement".to_s, :count => 2
    assert_select "tr>td", :text => "Categories".to_s, :count => 2
    assert_select "tr>td", :text => "Difficulty".to_s, :count => 2
    assert_select "tr>td", :text => "Requirements".to_s, :count => 2
    assert_select "tr>td", :text => "Workload".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
