# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'course_assignments/edit', type: :view do
  let(:course_assignment) do
    assign(:course_assignment, CourseAssignment.create!(
                                 name: 'MyString',
                                 maximum_score: 1.5,
                                 average_score: 1.5,
                                 course: nil
    ))
  end

  it 'renders the edit course_assignment form' do
    pending
    render

    assert_select 'form[action=?][method=?]', course_assignment_path(course_assignment), 'post' do
      assert_select 'input#course_assignment_name[name=?]', 'course_assignment[name]'

      assert_select 'input#course_assignment_maximum_score[name=?]', 'course_assignment[maximum_score]'

      assert_select 'input#course_assignment_average_score[name=?]', 'course_assignment[average_score]'

      assert_select 'input#course_assignment_course_id[name=?]', 'course_assignment[course_id]'
    end
  end
end
