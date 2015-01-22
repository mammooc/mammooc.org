require 'rails_helper'

RSpec.describe "course_results/new", :type => :view do
  before(:each) do
    assign(:course_result, CourseResult.new(
      :maximum_score => 1.5,
      :average_score => 1.5,
      :best_score => 1.5
    ))
  end

  it "renders new course_result form" do
    render

    assert_select "form[action=?][method=?]", course_results_path, "post" do

      assert_select "input#course_result_maximum_score[name=?]", "course_result[maximum_score]"

      assert_select "input#course_result_average_score[name=?]", "course_result[average_score]"

      assert_select "input#course_result_best_score[name=?]", "course_result[best_score]"
    end
  end
end
