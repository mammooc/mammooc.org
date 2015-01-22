require 'rails_helper'

RSpec.describe "groups/new", :type => :view do
  before(:each) do
    assign(:group, Group.new(
      :name => "MyString",
      :imageId => "MyString",
      :description => "MyText",
      :primary_statistics => ""
    ))
  end

  it "renders new group form" do
    render

    assert_select "form[action=?][method=?]", groups_path, "post" do

      assert_select "input#group_name[name=?]", "group[name]"

      assert_select "input#group_imageId[name=?]", "group[imageId]"

      assert_select "textarea#group_description[name=?]", "group[description]"

      assert_select "input#group_primary_statistics[name=?]", "group[primary_statistics]"
    end
  end
end
