# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { FactoryGirl.create(:fullUser) }

  before(:each) do
    @user = user
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(user.first_name)
    expect(rendered).to match(user.last_name)
    expect(rendered).to match(user.about_me)
  end
end
