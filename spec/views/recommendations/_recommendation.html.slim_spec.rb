# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'recommendations/_recommendation', type: :view do
  let(:user) { FactoryGirl.create(:user) }
  let!(:recommendation) { assign(:recommendation, FactoryGirl.create(:user_recommendation, users: [user])) }
  let!(:provider_logos) { assign(:provider_logos, {}) }
  let!(:profile_pictures) { assign(:profile_pictures, {}) }

  it 'renders the recommendation partial' do
    sign_in user
    render 'recommendations/recommendation', recommendation: recommendation, id: 'recommendation_number_1', group_context: false
    expect(rendered).to match(/#{recommendation.course.name}/)
    expect(rendered).to match(/#{recommendation.author.first_name} #{recommendation.author.last_name}/)
  end
end
