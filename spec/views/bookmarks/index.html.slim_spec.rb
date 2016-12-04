# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'bookmarks/index', type: :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:course, start_date: Time.zone.today) }
  let(:second_course) { FactoryGirl.create(:course, start_date: Time.zone.tomorrow, name: 'second course') }
  let!(:bookmark) { FactoryGirl.create(:bookmark, user: user, course: course) }
  let!(:second_bookmark) { FactoryGirl.create(:bookmark, user: user, course: second_course) }

  before do
    @bookmarked_courses = [course, second_course]
    @provider_logos = {}
    sign_in user
  end

  it 'renders a list of bookmarks' do
    render
    assert rendered, text: course.name, count: 1
    assert rendered, text: course.start_date.strftime(t('global.date_format_month')).to_s, count: 1
    assert rendered, text: second_course.name, count: 1
    assert rendered, text: second_course.start_date.strftime(t('global.date_format_month')).to_s, count: 1
  end
end
