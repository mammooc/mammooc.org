require 'rails_helper'

RSpec.describe "progresses/index", :type => :view do
  before(:each) do
    assign(:progresses, [
      Progress.create!(
        :percentage => 1.5,
        :permissions => "Permissions",
        :course => nil,
        :user => nil
      ),
      Progress.create!(
        :percentage => 1.5,
        :permissions => "Permissions",
        :course => nil,
        :user => nil
      )
    ])
  end

  it "renders a list of progresses" do
    render
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => "Permissions".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
