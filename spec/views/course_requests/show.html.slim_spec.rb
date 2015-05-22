# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'course_requests/show', type: :view do
  before(:each) do
    @course_request = assign(:course_request, CourseRequest.create!(
                                                description: 'MyText',
                                                course: nil,
                                                user: nil,
                                                group: nil
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
