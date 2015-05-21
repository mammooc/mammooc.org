# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'user_emails/index', type: :view do
  before(:each) do
    assign(:user_emails, [
      UserEmail.create!(
        address: 'valid@example.com',
        is_primary: true,
        user: nil,
        is_verified: false
      ),
      UserEmail.create!(
        address: 'valid2@example.com',
        is_primary: false,
        user: nil,
        is_verified: false
      )
    ])
  end

  it 'renders a list of emails' do
    render
    assert_select 'tr>td', text: 'valid@example.com'.to_s, count: 1
    assert_select 'tr>td', text: true.to_s, count: 1
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: 'valid2@example.com'.to_s, count: 1
    assert_select 'tr>td', text: false.to_s, count: 1
  end
end
