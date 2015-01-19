require 'rails_helper'

RSpec.describe "approvals/new", :type => :view do
  before(:each) do
    assign(:approval, Approval.new(
      :is_approved => false,
      :description => "MyString",
      :user => nil
    ))
  end

  it "renders new approval form" do
    render

    assert_select "form[action=?][method=?]", approvals_path, "post" do

      assert_select "input#approval_is_approved[name=?]", "approval[is_approved]"

      assert_select "input#approval_description[name=?]", "approval[description]"

      assert_select "input#approval_user_id[name=?]", "approval[user_id]"
    end
  end
end
