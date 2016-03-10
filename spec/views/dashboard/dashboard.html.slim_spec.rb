# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'dashboard/dashboard.html.slim', type: :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:full_course) }
  let(:second_course) { FactoryGirl.create(:full_course) }
  let(:recommendation) { FactoryGirl.create(:user_recommendation) }

  before(:each) do
    assign(:groups, [
             Group.create!(
               name: 'Name',
               description: 'MyText',
               primary_statistics: ''
             ),
             Group.create!(
               name: 'Name',
               description: 'MyText',
               primary_statistics: ''
             )
           ])
    assign(:courses, [
             FactoryGirl.create(:full_course),
             FactoryGirl.create(:full_course)
           ])
    @recommendations = [recommendation]
    sign_in user
    user.courses << course
    user.courses << second_course

    @provider_logos = {}
    @profile_pictures = {}
    @current_dates_to_show = []
  end

  it 'renders my enrollments' do
    render
    assert rendered, text: course.name, count: 2
  end

  it 'renders a list of groups' do
    render
    assert rendered, text: 'Name'.to_s, count: 2
    assert rendered, text: 'Image'.to_s, count: 2
    assert rendered, text: 'MyText'.to_s, count: 2
    assert rendered, text: ''.to_s, count: 2
  end
end
