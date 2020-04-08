# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { FactoryBot.create(:fullUser) }

  before do
    @user = user
  end

  it 'renders a profile page with all attributes' do
    render
    assert rendered, text: user.full_name, count: 1
    assert rendered, text: user.about_me, count: 1
  end
end
