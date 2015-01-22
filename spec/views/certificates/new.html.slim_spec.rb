require 'rails_helper'

RSpec.describe "certificates/new", :type => :view do
  before(:each) do
    assign(:certificate, Certificate.new(
      :title => "MyString",
      :file_id => "MyString",
      :completion => nil
    ))
  end

  it "renders new certificate form" do
    render

    assert_select "form[action=?][method=?]", certificates_path, "post" do

      assert_select "input#certificate_title[name=?]", "certificate[title]"

      assert_select "input#certificate_file_id[name=?]", "certificate[file_id]"

      assert_select "input#certificate_completion_id[name=?]", "certificate[completion_id]"
    end
  end
end
