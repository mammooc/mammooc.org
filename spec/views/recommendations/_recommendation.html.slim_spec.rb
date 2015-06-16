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

  it 'does not render course rating when there is no rating', js: true do
    sign_in user
    recommendation.course.reload
    render 'recommendations/recommendation', recommendation: recommendation, id: 'recommendation_number_1', group_context: false
    expect(rendered).not_to have_content("(#{recommendation.course.rating_count})")
  end

  it 'renders the course rating when it is present' do
    sign_in user
    FactoryGirl.create(:full_evaluation, user_id: user.id, course_id: recommendation.course.id)
    recommendation.course.reload
    render 'recommendations/recommendation', recommendation: recommendation, id: 'recommendation_number_1', group_context: false
    expect(rendered).to have_content("(#{recommendation.course.rating_count})")
  end

  it 'does not render course rating when it is zero' do
    sign_in user
    eva = FactoryGirl.create(:full_evaluation, user_id: user.id, course_id: recommendation.course.id)
    eva.destroy
    recommendation.course.reload
    render 'recommendations/recommendation', recommendation: recommendation, id: 'recommendation_number_1', group_context: false
    expect(rendered).not_to have_content("(#{recommendation.course.rating_count})")
  end

end
