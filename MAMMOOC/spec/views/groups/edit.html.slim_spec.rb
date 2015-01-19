require 'rails_helper'

RSpec.describe "groups/edit", :type => :view do
  before(:each) do
    @group = assign(:group, Group.create!(
      :name => "MyString",
      :imageId => "MyString",
      :description => "MyText",
      :primary_statistics => ""
    ))
  end

  it "renders the edit group form" do
    render

    assert_select "form[action=?][method=?]", group_path(@group), "post" do

      assert_select "input#group_name[name=?]", "group[name]"

      assert_select "input#group_imageId[name=?]", "group[imageId]"

      assert_select "textarea#group_description[name=?]", "group[description]"

      assert_select "input#group_primary_statistics[name=?]", "group[primary_statistics]"
    end
  end
end
