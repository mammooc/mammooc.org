require 'rails_helper'

RSpec.describe "groups/show", :type => :view do
  before(:each) do
    @group = assign(:group, Group.create!(
      :name => "Name",
      :imageId => "Image",
      :description => "MyText",
      :primary_statistics => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Image/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
  end
end
