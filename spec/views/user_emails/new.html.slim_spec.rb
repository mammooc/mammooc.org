# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'user_emails/new', type: :view do
  before(:each) do
    assign(:email, UserEmail.new(
                     address: 'valid@example.com',
                     is_primary: false,
                     user: nil,
                     is_verified: false
    ))
  end

  it 'renders new email form' do
    pending
    render

    assert_select 'form[action=?][method=?]', user_emails_path, 'post' do
      assert_select 'input#email_address[name=?]', 'email[address]'

      assert_select 'input#email_is_primary[name=?]', 'email[is_primary]'

      assert_select 'input#email_user_id[name=?]', 'email[user_id]'
    end
  end
end
