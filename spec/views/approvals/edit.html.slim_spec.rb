require 'rails_helper'


RSpec.describe "approvals/edit", :type => :view do
  before(:each) do
    @approval = assign(:approval, Approval.create!(
      :is_approved => false,
      :description => "MyString",
      :user => nil
    ))
  end

  it "renders the edit approval form" do
    pending
    render

    assert_select "form[action=?][method=?]", approval_path(@approval), "post" do

      assert_select "input#approval_is_approved[name=?]", "approval[is_approved]"

      assert_select "input#approval_description[name=?]", "approval[description]"

      assert_select "input#approval_user_id[name=?]", "approval[user_id]"
    end
  end
end
