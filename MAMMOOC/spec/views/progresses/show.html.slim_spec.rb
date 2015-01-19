require 'rails_helper'

RSpec.describe "progresses/show", :type => :view do
  before(:each) do
    @progress = assign(:progress, Progress.create!(
      :percentage => 1.5,
      :permissions => "Permissions",
      :course => nil,
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/Permissions/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
