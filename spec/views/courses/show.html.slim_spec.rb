# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'courses/show', type: :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:mooc_provider) { MoocProvider.create(name: 'open_mammooc', logo_id: 'logo_open_mammooc.png', url: 'https://example.com') }
  let!(:course) do
    assign(:course, Course.create!(
                      name: 'Name',
                      url: 'Url',
                      course_instructors: 'Course Instructor',
                      abstract: 'MyAbstract',
                      description: 'MyDescription',
                      language: 'en',
                      videoId: 'Video',
                      provider_given_duration: 'Duration',
                      categories: 'Categories',
                      difficulty: 'Difficulty',
                      requirements: 'Requirements',
                      workload: 'Workload',
                      provider_course_id: 1,
                      course_result: nil,
                      start_date: Time.zone.local(2015, 9, 3, 9),
                      end_date: Time.zone.local(2015, 10, 3, 9),
                      mooc_provider_id: mooc_provider.id,
                      tracks: [FactoryGirl.create(:course_track)]
    ))
  end
  let!(:provider_logos) { assign(:provider_logos, {}) }

  before(:each) do
    @recommendation = Recommendation.new
  end

  it 'render the enroll button when signed in but not enrolled in course' do
    sign_in user
    render
    expect(view.content_for(:content)).to have_selector("a[href='']")
    expect(view.content_for(:content)).to have_selector("a[id='enroll-link']")
    expect(view.content_for(:content)).to have_selector(".action-icon-enrollment[title='" + t('courses.course-list.enroll') + "']")
  end

  it 'render the unenroll button when signed in and already enrolled in course' do
    sign_in user
    user.courses << course
    render
    expect(view.content_for(:content)).to have_selector("a[id='unenroll-link']")
    expect(view.content_for(:content)).to have_selector(".action-icon-enrollment[title='" + t('courses.course-list.unenroll') + "']")
  end
end
