# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'evaluations/new', type: :view do
  before(:each) do
    assign(:evaluation, Evaluation.new(
                          title: 'MyString',
                          rating: 1.5,
                          is_verified: false,
                          description: 'MyText',
                          user: nil,
                          course: nil
    ))
  end

  it 'renders new evaluation form' do
    pending
    render

    assert_select 'form[action=?][method=?]', evaluations_path, 'post' do
      assert_select 'input#evaluation_title[name=?]', 'evaluation[title]'

      assert_select 'input#evaluation_rating[name=?]', 'evaluation[rating]'

      assert_select 'input#evaluation_is_verified[name=?]', 'evaluation[is_verified]'

      assert_select 'textarea#evaluation_description[name=?]', 'evaluation[description]'

      assert_select 'input#evaluation_user_id[name=?]', 'evaluation[user_id]'

      assert_select 'input#evaluation_course_id[name=?]', 'evaluation[course_id]'
    end
  end
end
