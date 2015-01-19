require 'rails_helper'

RSpec.describe "groups/index", :type => :view do
  before(:each) do
    assign(:groups, [
      Group.create!(
        :name => "Name",
        :imageId => "Image",
        :description => "MyText",
        :primary_statistics => ""
      ),
      Group.create!(
        :name => "Name",
        :imageId => "Image",
        :description => "MyText",
        :primary_statistics => ""
      )
    ])
  end

  it "renders a list of groups" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Image".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
