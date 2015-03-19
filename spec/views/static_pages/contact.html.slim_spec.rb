require 'rails_helper'

RSpec.describe "static_pages/contact.html.slim", :type => :view do
  it "renders caption" do
    render
    expect(rendered).to match(t('static.contact.heading'))
  end
end
