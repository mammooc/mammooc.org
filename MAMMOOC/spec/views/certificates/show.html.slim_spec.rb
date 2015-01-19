require 'rails_helper'

RSpec.describe "certificates/show", :type => :view do
  before(:each) do
    @certificate = assign(:certificate, Certificate.create!(
      :title => "Title",
      :file_id => "File",
      :completion => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/File/)
    expect(rendered).to match(//)
  end
end
