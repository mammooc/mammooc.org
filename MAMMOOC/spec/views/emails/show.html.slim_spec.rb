require 'rails_helper'

RSpec.describe "emails/show", :type => :view do
  before(:each) do
    @email = assign(:email, Email.create!(
      :address => "Address",
      :is_primary => false,
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(//)
  end
end
