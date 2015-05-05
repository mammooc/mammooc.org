# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'recommendations/_user_recommendation', type: :view do
  let!(:recommendation) { assign(:recommendation, FactoryGirl.create(:user_recommendation)) }
  let!(:provider_logos) { assign(:provider_logos, {}) }
  let!(:profile_pictures) { assign(:profile_pictures, {}) }

  it 'renders the recommendation partial' do
    render 'recommendations/user_recommendation', recommendation: recommendation, id: 'recommendation_number_1'
    expect(rendered).to match(/#{recommendation.course.name}/)
    expect(rendered).to match(/#{recommendation.author.first_name} #{recommendation.author.last_name}/)
  end
end
