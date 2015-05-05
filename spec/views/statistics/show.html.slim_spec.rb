# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'statistics/show', type: :view do
  before(:each) do
    @statistic = assign(:statistic, Statistic.create!(
                                      name: 'Name',
                                      result: 'MyText',
                                      group: nil
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
  end
end
