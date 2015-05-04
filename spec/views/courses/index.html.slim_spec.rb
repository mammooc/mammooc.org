require 'rails_helper'

RSpec.describe "courses/index", :type => :view do
  before(:each) do
    mooc_provider = FactoryGirl.create(:mooc_provider, name: 'open_mammooc')
    FactoryGirl.create_list(:full_course, 2, mooc_provider_id: mooc_provider.id)
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
