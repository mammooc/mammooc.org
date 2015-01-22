require 'rails_helper'

RSpec.describe "bookmarks/index", :type => :view do
  before(:each) do
    assign(:bookmarks, [
      Bookmark.create!(
        :user => nil,
        :course => nil
      ),
      Bookmark.create!(
        :user => nil,
        :course => nil
      )
    ])
  end

  it "renders a list of bookmarks" do
    pending
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
