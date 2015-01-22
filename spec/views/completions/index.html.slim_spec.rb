require 'rails_helper'

RSpec.describe "completions/index", :type => :view do
  before(:each) do
    assign(:completions, [
      Completion.create!(
        :position_in_course => 1,
        :points => 1.5,
        :permissions => "",
        :user => nil,
        :course => nil
      ),
      Completion.create!(
        :position_in_course => 1,
        :points => 1.5,
        :permissions => "",
        :user => nil,
        :course => nil
      )
    ])
  end

  it "renders a list of completions" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
