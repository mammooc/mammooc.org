# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'emails/index', type: :view do
  before(:each) do
    assign(:emails, [
      Email.create!(
        address: 'Address',
        is_primary: false,
        user: nil
      ),
      Email.create!(
        address: 'Address',
        is_primary: false,
        user: nil
      )
    ])
  end

  it 'renders a list of emails' do
    render
    assert_select 'tr>td', text: 'Address'.to_s, count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
  end
end
