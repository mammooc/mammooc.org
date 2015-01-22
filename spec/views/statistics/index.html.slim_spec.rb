require 'rails_helper'

RSpec.describe "statistics/index", :type => :view do
  before(:each) do
    assign(:statistics, [
      Statistic.create!(
        :name => "Name",
        :result => "MyText",
        :group => nil
      ),
      Statistic.create!(
        :name => "Name",
        :result => "MyText",
        :group => nil
      )
    ])
  end

  it "renders a list of statistics" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
