require 'rails_helper'

RSpec.describe "user_dates/edit", type: :view do
  before(:each) do
    @user_date = assign(:user_date, UserDate.create!(
      :user => nil,
      :course => nil,
      :mooc_provider => nil,
      :title => "MyString",
      :kind => "MyString",
      :relevant => false,
      :ressource_id_from_provider => "MyString"
    ))
  end

  it "renders the edit user_date form" do
    render

    assert_select "form[action=?][method=?]", user_date_path(@user_date), "post" do

      assert_select "input#user_date_user_id[name=?]", "user_date[user_id]"

      assert_select "input#user_date_course_id[name=?]", "user_date[course_id]"

      assert_select "input#user_date_mooc_provider_id[name=?]", "user_date[mooc_provider_id]"

      assert_select "input#user_date_title[name=?]", "user_date[title]"

      assert_select "input#user_date_kind[name=?]", "user_date[kind]"

      assert_select "input#user_date_relevant[name=?]", "user_date[relevant]"

      assert_select "input#user_date_ressource_id_from_provider[name=?]", "user_date[ressource_id_from_provider]"
    end
  end
end
