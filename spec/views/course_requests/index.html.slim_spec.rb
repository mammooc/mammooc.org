# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'course_requests/index', type: :view do
  before(:each) do
    assign(:course_requests, [
      CourseRequest.create!(
        description: 'MyText',
        course: nil,
        user: nil,
        group: nil
      ),
      CourseRequest.create!(
        description: 'MyText',
        course: nil,
        user: nil,
        group: nil
      )
    ])
  end

  it 'renders a list of course_requests' do
    pending
    render
    assert_select 'tr>td', text: 'MyText'.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
  end
end
