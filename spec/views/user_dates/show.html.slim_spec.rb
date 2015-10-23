require 'rails_helper'

RSpec.describe "user_dates/show", type: :view do
  before(:each) do
    @user_date = assign(:user_date, UserDate.create!(
      :user => nil,
      :course => nil,
      :mooc_provider => nil,
      :title => "Title",
      :kind => "Kind",
      :relevant => false,
      :ressource_id_from_provider => "Ressource Id From Provider"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Kind/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Ressource Id From Provider/)
  end
end
