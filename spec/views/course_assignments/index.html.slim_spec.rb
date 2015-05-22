# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'course_assignments/index', type: :view do
  before(:each) do
    assign(:course_assignments, [
      CourseAssignment.create!(
        name: 'Name',
        maximum_score: 1.5,
        average_score: 1.5,
        course: nil
      ),
      CourseAssignment.create!(
        name: 'Name',
        maximum_score: 1.5,
        average_score: 1.5,
        course: nil
      )
    ])
  end

  it 'renders a list of course_assignments' do
    pending
    render
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
    assert_select 'tr>td', text: 1.5.to_s, count: 2
    assert_select 'tr>td', text: 1.5.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
  end
end
