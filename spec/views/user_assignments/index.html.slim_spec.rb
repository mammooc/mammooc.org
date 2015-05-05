# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'user_assignments/index', type: :view do
  before(:each) do
    assign(:user_assignments, [
      UserAssignment.create!(
        score: 1.5,
        user: nil,
        course: nil,
        course_assignment: nil
      ),
      UserAssignment.create!(
        score: 1.5,
        user: nil,
        course: nil,
        course_assignment: nil
      )
    ])
  end

  it 'renders a list of user_assignments' do
    pending
    render
    assert_select 'tr>td', text: 1.5.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
  end
end
