# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'recommendations/index', type: :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:course) }
  let(:author) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group, users: [user, author]) }
  let(:first_recommendation) { FactoryGirl.create(:user_recommendation, author: author, course: course,  users: [user]) }
  let(:second_recommendation) { FactoryGirl.create(:user_recommendation, author: author, course: course,  users: [user]) }

  before(:each) do
    @recommendations = [first_recommendation, second_recommendation]
    @provider_logos = {}
    @profile_pictures = {}
  end

  it 'renders a list of recommendations' do
    sign_in user
    render
    expect(rendered).to match(/#{first_recommendation.course.name}/)
    expect(rendered).to match(/#{second_recommendation.course.name}/)
    expect(rendered).to match(/#{first_recommendation.author.first_name} #{first_recommendation.author.last_name}/)
    expect(rendered).to match(/#{second_recommendation.author.first_name} #{second_recommendation.author.last_name}/)
  end
end
