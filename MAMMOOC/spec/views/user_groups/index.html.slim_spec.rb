require 'rails_helper'

RSpec.describe "user_groups/index", :type => :view do
  before(:each) do
    assign(:user_groups, [
      UserGroup.create!(
        :is_admin => false,
        :user => nil,
        :group => nil
      ),
      UserGroup.create!(
        :is_admin => false,
        :user => nil,
        :group => nil
      )
    ])
  end

  it "renders a list of user_groups" do
    render
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
