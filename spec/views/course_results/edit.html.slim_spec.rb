require 'rails_helper'

RSpec.describe "course_results/edit", :type => :view do
  before(:each) do
    @course_result = assign(:course_result, CourseResult.create!(
      :maximum_score => 1.5,
      :average_score => 1.5,
      :best_score => 1.5
    ))
  end

  it "renders the edit course_result form" do
    render

    assert_select "form[action=?][method=?]", course_result_path(@course_result), "post" do

      assert_select "input#course_result_maximum_score[name=?]", "course_result[maximum_score]"

      assert_select "input#course_result_average_score[name=?]", "course_result[average_score]"

      assert_select "input#course_result_best_score[name=?]", "course_result[best_score]"
    end
  end
end
