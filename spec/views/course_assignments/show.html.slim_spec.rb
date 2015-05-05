# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'course_assignments/show', type: :view do
  before(:each) do
    @course_assignment = assign(:course_assignment, CourseAssignment.create!(
                                                      name: 'Name',
                                                      maximum_score: 1.5,
                                                      average_score: 1.5,
                                                      course: nil
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(//)
  end
end
