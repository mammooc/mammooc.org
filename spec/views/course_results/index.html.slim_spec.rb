require 'rails_helper'

RSpec.describe "course_results/index", :type => :view do
  before(:each) do
    assign(:course_results, [
      CourseResult.create!(
        :maximum_score => 1.5,
        :average_score => 1.5,
        :best_score => 1.5
      ),
      CourseResult.create!(
        :maximum_score => 1.5,
        :average_score => 1.5,
        :best_score => 1.5
      )
    ])
  end

  it "renders a list of course_results" do
    pending
    render
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
