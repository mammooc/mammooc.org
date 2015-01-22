require 'rails_helper'

RSpec.describe "certificates/edit", :type => :view do
  before(:each) do
    @certificate = assign(:certificate, Certificate.create!(
      :title => "MyString",
      :file_id => "MyString",
      :completion => nil
    ))
  end

  it "renders the edit certificate form" do
    pending
    render

    assert_select "form[action=?][method=?]", certificate_path(@certificate), "post" do

      assert_select "input#certificate_title[name=?]", "certificate[title]"

      assert_select "input#certificate_file_id[name=?]", "certificate[file_id]"

      assert_select "input#certificate_completion_id[name=?]", "certificate[completion_id]"
    end
  end
end
