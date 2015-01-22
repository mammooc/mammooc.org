require 'rails_helper'

RSpec.describe "certificates/index", :type => :view do
  before(:each) do
    assign(:certificates, [
      Certificate.create!(
        :title => "Title",
        :file_id => "File",
        :completion => nil
      ),
      Certificate.create!(
        :title => "Title",
        :file_id => "File",
        :completion => nil
      )
    ])
  end

  it "renders a list of certificates" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "File".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
