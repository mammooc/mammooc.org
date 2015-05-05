# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'static_pages/impressum.html.slim', type: :view do
  it 'renders caption' do
    render
    expect(rendered).to match(t('static.impressum.heading'))
  end
end
