# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'emails/new', type: :view do
  before(:each) do
    assign(:email, Email.new(
                     address: 'MyString',
                     is_primary: false,
                     user: nil
    ))
  end

  it 'renders new email form' do
    pending
    render

    assert_select 'form[action=?][method=?]', emails_path, 'post' do
      assert_select 'input#email_address[name=?]', 'email[address]'

      assert_select 'input#email_is_primary[name=?]', 'email[is_primary]'

      assert_select 'input#email_user_id[name=?]', 'email[user_id]'
    end
  end
end
