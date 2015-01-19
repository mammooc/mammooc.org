require 'rails_helper'

RSpec.describe "courses/show", :type => :view do
  before(:each) do
    @course = assign(:course, Course.create!(
      :name => "Name",
      :url => "Url",
      :course_instructor => "Course Instructor",
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
      :workload => "Workload",
      :provider_course_id => 1,
      :mooc_provider => nil,
      :course_result => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Url/)
    expect(rendered).to match(/Course Instructor/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Language/)
    expect(rendered).to match(/Image/)
    expect(rendered).to match(/Video/)
    expect(rendered).to match(/Duration/)
    expect(rendered).to match(/Costs/)
    expect(rendered).to match(/Type Of Achievement/)
    expect(rendered).to match(/Categories/)
    expect(rendered).to match(/Difficulty/)
    expect(rendered).to match(/Requirements/)
    expect(rendered).to match(/Workload/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
