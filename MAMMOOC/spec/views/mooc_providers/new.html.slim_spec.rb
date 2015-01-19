require 'rails_helper'

RSpec.describe "mooc_providers/new", :type => :view do
  before(:each) do
    assign(:mooc_provider, MoocProvider.new(
      :logo_id => "MyString",
      :name => "MyString",
      :url => "MyString",
      :description => "MyText"
    ))
  end

  it "renders new mooc_provider form" do
    render

    assert_select "form[action=?][method=?]", mooc_providers_path, "post" do

      assert_select "input#mooc_provider_logo_id[name=?]", "mooc_provider[logo_id]"

      assert_select "input#mooc_provider_name[name=?]", "mooc_provider[name]"

      assert_select "input#mooc_provider_url[name=?]", "mooc_provider[url]"

      assert_select "textarea#mooc_provider_description[name=?]", "mooc_provider[description]"
    end
  end
end
