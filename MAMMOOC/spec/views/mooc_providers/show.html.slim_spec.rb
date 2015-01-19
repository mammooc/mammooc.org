require 'rails_helper'

RSpec.describe "mooc_providers/show", :type => :view do
  before(:each) do
    @mooc_provider = assign(:mooc_provider, MoocProvider.create!(
      :logo_id => "Logo",
      :name => "Name",
      :url => "Url",
      :description => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Logo/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Url/)
    expect(rendered).to match(/MyText/)
  end
end
