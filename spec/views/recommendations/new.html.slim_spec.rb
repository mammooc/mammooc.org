# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'recommendations/new', type: :view do
  before(:each) do
    assign(:recommendation, Recommendation.new(
                              is_obligatory: false,
                              author: nil,
                              course: nil,
                              text: nil
    ))
  end

  it 'renders new recommendation form' do
    render

    assert_select 'form[action=?][method=?]', recommendations_path, 'post' do
      assert_select 'input#recommendation_related_user_ids[name=?]', 'recommendation[related_user_ids]'

      assert_select 'input#recommendation_related_group_ids[name=?]', 'recommendation[related_group_ids]'

      assert_select 'input#recommendation_course_id[name=?]', 'recommendation[course_id]'

      assert_select 'textarea#recommendation_text[name=?]', 'recommendation[text]'
    end
  end
end
