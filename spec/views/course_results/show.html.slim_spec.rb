require 'rails_helper'

RSpec.describe "course_results/show", :type => :view do
  before(:each) do
    @course_result = assign(:course_result, CourseResult.create!(
      :maximum_score => 1.5,
      :average_score => 1.5,
      :best_score => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/1.5/)
  end
end
