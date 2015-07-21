# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe EdxCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'edX') }

  let(:edx_course_worker) { described_class.new }

  let(:course_data) do
    '{"count":475,"value":{"title":"EdX RSS to JSON pipe","description":"Pipes Output","link":"http:\/\/pipes.yahoo.com\/pipes\/pipe.info?_id=74859f52b084a75005251ae7a119f371","pubDate":"Tue, 07 Apr 2015 12:16:40 +0000","generator":"http:\/\/pipes.yahoo.com\/pipes\/","callback":"","items":[{"guid":"https:\/\/www.edx.org\/node\/4116","title":"DemoX","link":"https:\/\/www.edx.org\/course\/demox-edx-demox-1","description":"This brief course is designed to show new students how to take a course on edX. You will learn how to navigate the edX platform and complete your first course! From there, we will help you get started choosing the course that best fits your interests, needs, and dreams.\n\nHave questions before taking the demo course? Check our student FAQs.","pubDate":"Mon, 06 Apr 2015 18:13:23 -0400","course:id":"edX\/DemoX.1\/2014","course:code":"DemoX.1","course:created":"Mon, 15 Sep 2014 10:37:30 -0400","course:start":"2013-07-07 00:00:00","course:end":"2013-08-08 00:00:00","course:subtitle":"<p>A fun and interactive course designed to help you explore the edX learning experience.  Perfect to take before you start your course.<\/p>","course:subject":["Biology & Life Sciences","Business & Management","Chemistry","Computer Science","Economics & Finance","Electronics","Energy & Earth Sciences","Engineering","Environmental Studies","Food & Nutrition","Health & Safety","History","Humanities","Law","Literature","Math","Medicine","Philosophy & Ethics","Physics","Science","Social Sciences","Statistics & Data Analysis"],"course:school":"edX","course:staff":["Raphael Valenti","James Donald","Erik Brown"],"course:video-youtube":"http:\/\/www.youtube.com\/watch?v=1u_QKOrXyMM","course:video-file":null,"course:image-banner":"https:\/\/www.edx.org\/sites\/default\/files\/course\/image\/banner\/demox_608x211_0.jpg","course:image-thumbnail":"https:\/\/www.edx.org\/sites\/default\/files\/course\/image\/promoted\/demox_378x225_0.jpg","course:verified":"0","course:xseries":"0","course:highschool":"0","course:profed":"0","course:effort":"From 10 - 30 minutes, or as much time as you want.","course:length":"2 Weeks","course:prerequisites":"None","y:published":{"hour":"22","timezone":"UTC","second":"23","month":"4","month_name":"April","minute":"13","utime":"1428358403","day":"6","day_ordinal_suffix":"th","day_of_week":"1","day_name":"Monday","year":"2015"},"y:id":{"permalink":"false","value":"https:\/\/www.edx.org\/node\/4116"},"y:title":"DemoX"}]}}'
  end
  let(:json_course_data) { JSON.parse course_data }
  let!(:free_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'nothing' }
  let!(:certificate_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'edx_verified_certificate' }
  let!(:xseries_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'edx_xseries_verified_certificate' }
  let!(:profed_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'edx_profed_certificate' }

  it 'delivers MOOCProvider' do
    expect(edx_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'gets an API response' do
    expect(edx_course_worker.course_data).not_to be_nil
  end

  it 'loads new course into database' do
    expect { edx_course_worker.handle_response_data json_course_data }.to change(Course, :count).by(1)
  end

  it 'loads course attributes into database' do
    edx_course_worker.handle_response_data json_course_data

    json_course = json_course_data['value']['items'][0]
    course = Course.find_by(provider_course_id: json_course['course:id'], mooc_provider_id: mooc_provider.id)

    expect(course.name).to eql json_course['title']
    expect(course.provider_course_id).to eql json_course['course:id']
    expect(course.mooc_provider_id).to eql mooc_provider.id
    expect(course.url).to eql json_course['link']
    expect(course.course_image).not_to eql nil
    expect(course.start_date).to eq Time.zone.parse(json_course['course:start']).in_time_zone
    expect(course.end_date).to eq Time.zone.parse(json_course['course:end']).in_time_zone
    expect(course.provider_given_duration).to eql json_course['course:length']
    expect(course.requirements).to include json_course['course:prerequisites']
    expect(course.categories).to include json_course['course:subject'][0]
    expect(course.description).to eql json_course['description']
    expect(course.course_instructors).to include json_course['course:staff'][0]
    expect(course.tracks.count).to eql 1
    expect(course.tracks[0].track_type.type_of_achievement).to eql free_course_track_type.type_of_achievement
    expect(course.tracks[0].costs).to eql 0.0
    expect(course.tracks[0].credit_points).to be_nil
  end

  it 'does not duplicate courses' do
    allow(RestClient).to receive(:get).and_return(course_data)
    edx_course_worker.load_courses
    expect { edx_course_worker.load_courses }.to change { Course.count }.by(0)
  end

  it 'creates courses with other data types for instructires, categories as well' do
    json_course = json_course_data['value']['items'][0]
    json_course['course:staff'] = 'Person A, Person B'
    json_course['course:subject'] = 'Topic'
    edx_course_worker.handle_response_data json_course_data
    course = Course.find_by(provider_course_id: json_course['course:id'], mooc_provider_id: mooc_provider.id)
    expect(course.course_instructors).to eql json_course['course:staff']
    expect(course.categories).to eql [json_course['course:subject']]
  end

  it 'creates a certificate course track type' do
    json_course = json_course_data['value']['items'][0]
    json_course['course:verified'] = '1'
    edx_course_worker.handle_response_data json_course_data
    course = Course.find_by(provider_course_id: json_course['course:id'], mooc_provider_id: mooc_provider.id)
    (course.tracks).each do |course_track|
      case course_track.track_type
        when free_course_track_type then
          expect(course_track.track_type.type_of_achievement).to eql free_course_track_type.type_of_achievement
          expect(course_track.costs).to eql 0.0
          expect(course_track.credit_points).to be_nil
        when certificate_course_track_type then
          expect(course_track.track_type.type_of_achievement).to eql certificate_course_track_type.type_of_achievement
          expect(course_track.costs).to be_nil
          expect(course_track.credit_points).to be_nil
      end
    end
  end

  it 'creates a xseries course track type' do
    json_course = json_course_data['value']['items'][0]
    json_course['course:xseries'] = '1'
    edx_course_worker.handle_response_data json_course_data
    course = Course.find_by(provider_course_id: json_course['course:id'], mooc_provider_id: mooc_provider.id)
    (course.tracks).each do |course_track|
      case course_track.track_type
        when free_course_track_type then
          expect(course_track.track_type.type_of_achievement).to eql free_course_track_type.type_of_achievement
          expect(course_track.costs).to eql 0.0
          expect(course_track.credit_points).to be_nil
        when xseries_course_track_type then
          expect(course_track.track_type.type_of_achievement).to eql xseries_course_track_type.type_of_achievement
          expect(course_track.costs).to be_nil
          expect(course_track.credit_points).to be_nil
      end
    end
  end

  it 'creates a profed course track type' do
    json_course = json_course_data['value']['items'][0]
    json_course['course:profed'] = '1'
    edx_course_worker.handle_response_data json_course_data
    course = Course.find_by(provider_course_id: json_course['course:id'], mooc_provider_id: mooc_provider.id)
    expect(course.tracks[0].track_type.type_of_achievement).to eql profed_course_track_type.type_of_achievement
    expect(course.tracks[0].costs).to be_nil
    expect(course.tracks[0].credit_points).to be_nil
  end
end
