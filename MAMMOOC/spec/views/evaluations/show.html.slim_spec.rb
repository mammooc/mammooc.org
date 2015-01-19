require 'rails_helper'

RSpec.describe "evaluations/show", :type => :view do
  before(:each) do
    @evaluation = assign(:evaluation, Evaluation.create!(
      :title => "Title",
      :rating => 1.5,
      :is_verified => false,
      :description => "MyText",
      :user => nil,
      :course => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
