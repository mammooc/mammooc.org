require 'rails_helper'

RSpec.describe "mooc_providers/index", :type => :view do
  before(:each) do
    assign(:mooc_providers, [
      MoocProvider.create!(
        :logo_id => "Logo",
        :name => "Name1",
        :url => "Url",
        :description => "MyText"
      ),
      MoocProvider.create!(
        :logo_id => "Logo",
        :name => "Name2",
        :url => "Url",
        :description => "MyText"
      )
    ])
  end

  it "renders a list of mooc_providers" do
    render
    assert_select "tr>td", :text => "Logo".to_s, :count => 2
    assert_select "tr>td", :text => "Name1".to_s, :count => 1
    assert_select "tr>td", :text => "Name2".to_s, :count => 1
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
