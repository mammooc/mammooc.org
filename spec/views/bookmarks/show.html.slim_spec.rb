# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'bookmarks/show', type: :view do
  before(:each) do
    @bookmark = assign(:bookmark, Bookmark.create!(
                                    user: nil,
                                    course: nil
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
