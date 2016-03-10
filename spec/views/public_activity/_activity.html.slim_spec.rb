# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'layouts/_activity', type: :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:author) { FactoryGirl.create(:user) }
  let!(:activity) { assign(:activity, FactoryGirl.create(:activity_bookmark, user_ids: [user.id])) }
  let(:course) { FactoryGirl.create(:course) }
  let!(:provider_logos) { assign(:provider_logos, {}) }
  let!(:profile_pictures) { assign(:profile_pictures, {}) }

  it 'renders the activity partial' do
    sign_in user
    render 'layouts/activity', activity: activity, author: author, course: course, bookmarked: false, group_context: false, user_is_admin: false, signed_in_user: user
    expect(rendered).to match(/#{course.name}/)
  end

  it 'does not render course rating when there is no rating', js: true do
    sign_in user
    course.reload
    render 'layouts/activity', activity: activity, author: author, course: course, bookmarked: false, group_context: false, user_is_admin: false, signed_in_user: user
    expect(rendered).not_to have_content("(#{course.rating_count})")
  end

  it 'renders the course rating when it is present' do
    sign_in user
    FactoryGirl.create(:full_evaluation, user_id: user.id, course_id: course.id)
    course.reload
    render 'layouts/activity', activity: activity, author: author, course: course, bookmarked: false, group_context: false, user_is_admin: false, signed_in_user: user
    expect(rendered).to have_content("(#{course.rating_count})")
  end

  it 'does not render course rating when it is zero' do
    sign_in user
    eva = FactoryGirl.create(:full_evaluation, user_id: user.id, course_id: course.id)
    eva.destroy
    course.reload
    render 'layouts/activity', activity: activity, author: author, course: course, bookmarked: false, group_context: false, user_is_admin: false, signed_in_user: user
    expect(rendered).not_to have_content("(#{course.rating_count})")
  end
end
