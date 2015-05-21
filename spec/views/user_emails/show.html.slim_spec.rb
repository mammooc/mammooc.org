# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'user_emails/show', type: :view do
  before(:each) do
    @email = assign(:email, UserEmail.create!(
                              address: 'valid@example.com',
                              is_primary: true,
                              user: nil,
                              is_verified: false
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/true/)
    expect(rendered).to match(//)
  end
end
