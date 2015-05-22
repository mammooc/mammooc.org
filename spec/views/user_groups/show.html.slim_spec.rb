# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'user_groups/show', type: :view do
  before(:each) do
    @user_group = assign(:user_group, UserGroup.create!(
                                        is_admin: false,
                                        user: nil,
                                        group: nil
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/false/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
