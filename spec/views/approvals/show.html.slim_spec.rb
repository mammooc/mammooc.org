# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'approvals/show', type: :view do
  before(:each) do
    @approval = assign(:approval, Approval.create!(
                                    is_approved: false,
                                    description: 'Description',
                                    user: nil
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(//)
  end
end
