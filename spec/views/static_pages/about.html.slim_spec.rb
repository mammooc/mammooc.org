# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'static_pages/about.html.slim', type: :view do
  it 'renders caption' do
    render
    expect(rendered).to match(t('static.about.heading'))
  end
end
