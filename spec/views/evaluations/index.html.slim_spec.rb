# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'evaluations/index', type: :view do
  before(:each) do
    assign(:evaluations, [
      Evaluation.create!(
        title: 'Title',
        rating: 1.5,
        is_verified: false,
        description: 'MyText',
        user: nil,
        course: nil
      ),
      Evaluation.create!(
        title: 'Title',
        rating: 1.5,
        is_verified: false,
        description: 'MyText',
        user: nil,
        course: nil
      )
    ])
  end

  it 'renders a list of evaluations' do
    pending
    render
    assert_select 'tr>td', text: 'Title'.to_s, count: 2
    assert_select 'tr>td', text: 1.5.to_s, count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
    assert_select 'tr>td', text: 'MyText'.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
  end
end
