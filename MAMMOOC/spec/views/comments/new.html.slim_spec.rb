require 'rails_helper'

RSpec.describe "comments/new", :type => :view do
  before(:each) do
    assign(:comment, Comment.new(
      :content => "MyText",
      :user => nil,
      :recommendation => nil
    ))
  end

  it "renders new comment form" do
    render

    assert_select "form[action=?][method=?]", comments_path, "post" do

      assert_select "textarea#comment_content[name=?]", "comment[content]"

      assert_select "input#comment_user_id[name=?]", "comment[user_id]"

      assert_select "input#comment_recommendation_id[name=?]", "comment[recommendation_id]"
    end
  end
end
