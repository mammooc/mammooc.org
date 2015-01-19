require 'rails_helper'

RSpec.describe "completions/show", :type => :view do
  before(:each) do
    @completion = assign(:completion, Completion.create!(
      :position_in_course => 1,
      :points => 1.5,
      :permissions => "",
      :user => nil,
      :course => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
