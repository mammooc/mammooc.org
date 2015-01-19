require 'rails_helper'

RSpec.describe "user_assignments/show", :type => :view do
  before(:each) do
    @user_assignment = assign(:user_assignment, UserAssignment.create!(
      :score => 1.5,
      :user => nil,
      :course => nil,
      :course_assignment => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
