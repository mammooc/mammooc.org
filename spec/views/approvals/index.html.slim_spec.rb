require 'rails_helper'

RSpec.describe "approvals/index", :type => :view do
  before(:each) do
    assign(:approvals, [
      Approval.create!(
        :is_approved => false,
        :description => "Description",
        :user => nil
      ),
      Approval.create!(
        :is_approved => false,
        :description => "Description",
        :user => nil
      )
    ])
  end

  it "renders a list of approvals" do
    pending
    render
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
