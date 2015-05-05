# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'bookmarks/edit', type: :view do
  let(:bookmark) do
    assign(:bookmark, Bookmark.create!(
                        user: nil,
                        course: nil
    ))
  end

  it 'renders the edit bookmark form' do
    pending
    render

    assert_select 'form[action=?][method=?]', bookmark_path(bookmark), 'post' do
      assert_select 'input#bookmark_user_id[name=?]', 'bookmark[user_id]'

      assert_select 'input#bookmark_course_id[name=?]', 'bookmark[course_id]'
    end
  end
end
