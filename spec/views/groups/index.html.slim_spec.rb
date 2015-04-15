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
    assert rendered, :text => "Name".to_s, :count => 2
    assert rendered, :text => "Image".to_s, :count => 2
    assert rendered, :text => "MyText".to_s, :count => 2
    assert rendered, :text => "".to_s, :count => 2
  end
end
