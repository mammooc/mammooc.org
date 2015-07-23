# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'support/course_worker_spec_helper'

RSpec.describe CourseraCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'coursera') }

  let(:coursera_course_worker) { described_class.new }

  let(:json_session_data) do
    JSON.parse '{"elements":[{"id":90,"courseId":9,"homeLink":"https://class.coursera.org/crypto-2012-002/","active":true,"durationString":"6 weeks","startDay":11,"startMonth":6,"startYear":2012,"eligibleForCertificates":true,"eligibleForSignatureTrack":false,"links":{}},{"id":91,"courseId":9,"homeLink":"https://class.coursera.org/crypto-2012-002/","active":true,"durationString":"6 weeks","startDay":13,"startMonth":6,"startYear":2012,"eligibleForCertificates":true,"eligibleForSignatureTrack":false,"links":{}}],"linked":{}}'
  end
  let(:course_fields) do
    '{"elements":[{"id":9,"shortName":"crypto","name":"Cryptography I","language":"en","photo":"https://s3.amazonaws.com/coursera/topics/crypto/large-icon.png","shortDescription":"Learn about the inner workings of cryptographic primitives and how to apply this knowledge in real-world applications!","subtitleLanguagesCsv":"","video":"0t1oCt88XJk","aboutTheCourse":"<p>Cryptography is an indispensable tool for protecting information in computer systems. This course explains the inner workings of cryptographic primitives and how to correctly use them. Students will learn how to reason about the security of cryptographic constructions and how to apply this knowledge to real-world applications. The course begins with a detailed discussion of how two parties who have a shared secret key can communicate securely when a powerful adversary eavesdrops and tampers with traffic. We will examine many deployed protocols and analyze mistakes in existing systems. The second half of the course discusses public-key techniques that let two or more parties generate a shared secret key. We will cover the relevant number theory and discuss public-key encryption and basic key-exchange.&nbsp;Throughout the course students will be exposed to many exciting open problems in the field.</p>\n<p>The course will include written homeworks and programming labs. The course is self-contained, however it will be helpful to have a basic understanding of discrete probability theory.</p><p>A preview of the course, including lectures and homework assignments, is available at this <a href=\"https://class.coursera.org/crypto-preview\" target=\"_blank\">preview site</a>.</p>","targetAudience":1,"instructor":"Dan Boneh, Professor","estimatedClassWorkload":"5-7 hours/week","recommendedBackground":"","links":{}}],"linked":{}}'
  end
  let(:json_course_data) { JSON.parse course_fields }
  let!(:free_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'nothing' }
  let!(:certificate_course_track_type) { FactoryGirl.create :certificate_course_track_type }
  let!(:signature_course_track_type) { FactoryGirl.create :signature_course_track_type }

  it 'delivers MOOCProvider' do
    expect(coursera_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'gets an API response' do
    expect(coursera_course_worker.course_data).not_to be_nil
  end

  it 'loads new course into database' do
    allow(RestClient).to receive(:get).and_return(course_fields)
    expect { coursera_course_worker.handle_response_data json_session_data }.to change(Course, :count).by(2)
  end

  it 'loads course attributes into database' do
    allow(RestClient).to receive(:get).and_return(course_fields)
    coursera_course_worker.handle_response_data json_session_data
    json_session = json_session_data['elements'][0]
    json_course = json_course_data['elements'][0]
    course = Course.find_by(provider_course_id: json_course['id'].to_s + '|' + json_session['id'].to_s, mooc_provider_id: mooc_provider.id)

    expect(course.name).to eql json_course['name']
    expect(course.provider_course_id).to eql json_course['id'].to_s + '|' + json_session['id'].to_s
    expect(course.mooc_provider_id).to eql mooc_provider.id
    expect(course.calculated_duration_in_days).to eql 42
    expect(course.url).to include json_course['shortName']
    expect(course.language).to eql json_course['language']
    expect(course.start_date).to eql Time.zone.parse Time.zone.local(json_session['startYear'], json_session['startMonth'], json_session['startDay']).to_s
    expect(course.abstract).to eql json_course['shortDescription']
    expect(course.course_instructors).to eql json_course['instructor']
    expect(course.provider_given_duration).to eql json_session['durationString']
    expect(course.subtitle_languages).to eql json_course['subtitleLanguagesCsv']
    expect(course.videoId).to eql json_course['video']
    expect(course.description).to eql json_course['aboutTheCourse']
    expect(course.workload).to eql json_course['estimatedClassWorkload']
    expect(course.difficulty).to eql 'Advanced undergraduates or beginning graduates'
    expect(course.requirements).to eql nil
    expect(course.tracks.count).to eql 2
    expect(achievement_type? course.tracks, :nothing).to be_truthy
    expect(achievement_type? course.tracks, :certificate).to be_truthy
  end

  it 'links iterations in correct order' do
    allow(RestClient).to receive(:get).and_return(course_fields)
    coursera_course_worker.handle_response_data json_session_data
    json_course = json_course_data['elements'][0]
    json_session1 = json_session_data['elements'][0]
    json_session2 = json_session_data['elements'][1]
    course1 = Course.find_by(provider_course_id: json_course['id'].to_s + '|' + json_session1['id'].to_s, mooc_provider_id: mooc_provider.id)
    course2 = Course.find_by(provider_course_id: json_course['id'].to_s + '|' + json_session2['id'].to_s, mooc_provider_id: mooc_provider.id)
    expect(course1.following_iteration_id).to eql course2.id
    expect(course2.previous_iteration_id).to eql course1.id
  end

  it 'does not duplicate courses' do
    allow(RestClient).to receive(:get).and_return(course_fields)
    coursera_course_worker.handle_response_data json_session_data
    expect { coursera_course_worker.handle_response_data json_session_data }.to change { Course.count }.by(0)
  end

  it 'parses prerequirements to an array' do
    json_course_data['elements'][0]['recommendedBackground'] = 'an internet connection'
    allow(RestClient).to receive(:get).and_return(json_course_data.to_json)
    coursera_course_worker.handle_response_data json_session_data
    json_session = json_session_data['elements'][0]
    json_course = json_course_data['elements'][0]
    course = Course.find_by(provider_course_id: json_course['id'].to_s + '|' + json_session['id'].to_s, mooc_provider_id: mooc_provider.id)
    expect(course.requirements).to eql [json_course_data['elements'][0]['recommendedBackground']]
  end

  it 'creates a signature course track type with regular price' do
    json_session = json_session_data['elements'][0]
    json_course = json_course_data['elements'][0]
    json_session['eligibleForSignatureTrack'] = true
    json_session['signatureTrackRegularPrice'] = '100.0'
    allow(RestClient).to receive(:get).and_return(course_fields)
    coursera_course_worker.handle_response_data json_session_data
    course = Course.find_by(provider_course_id: json_course['id'].to_s + '|' + json_session['id'].to_s, mooc_provider_id: mooc_provider.id)
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
        when signature_course_track_type then
          expect(course_track.costs).to eql 100.0
          expect(course_track.costs_currency).to eql '$'
          expect(course_track.credit_points).to be_nil
      end
    end
  end

  it 'creates a signature course track type with price' do
    json_session = json_session_data['elements'][0]
    json_course = json_course_data['elements'][0]
    json_session['eligibleForSignatureTrack'] = true
    json_session['signatureTrackPrice'] = '50.0'
    json_session['signatureTrackRegularPrice'] = '100.0'
    allow(RestClient).to receive(:get).and_return(course_fields)
    coursera_course_worker.handle_response_data json_session_data
    course = Course.find_by(provider_course_id: json_course['id'].to_s + '|' + json_session['id'].to_s, mooc_provider_id: mooc_provider.id)
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
        when signature_course_track_type then
          expect(course_track.costs).to eql 50.0
          expect(course_track.costs_currency).to eql '$'
          expect(course_track.credit_points).to be_nil
      end
    end
  end

  it 'sets the targetAudience to Basic Undergraduate' do
    json_course = json_course_data['elements'][0]
    json_session = json_session_data['elements'][0]
    json_course['targetAudience'] = 0
    allow(RestClient).to receive(:get).and_return(json_course_data.to_json)
    coursera_course_worker.handle_response_data json_session_data
    course = Course.find_by(provider_course_id: json_course['id'].to_s + '|' + json_session['id'].to_s, mooc_provider_id: mooc_provider.id)
    expect(course.difficulty).to eql 'Basic Undergraduates'
  end

  it 'sets the targetAudience to Advanced graduates' do
    json_course = json_course_data['elements'][0]
    json_session = json_session_data['elements'][0]
    json_course['targetAudience'] = 2
    allow(RestClient).to receive(:get).and_return(json_course_data.to_json)
    coursera_course_worker.handle_response_data json_session_data
    course = Course.find_by(provider_course_id: json_course['id'].to_s + '|' + json_session['id'].to_s, mooc_provider_id: mooc_provider.id)
    expect(course.difficulty).to eql 'Advanced graduates'
  end

  it 'deletes useless iterations without start date' do
    json_session_data['elements'][1]['startDay'] = nil
    json_session_data['elements'][1]['startMonth'] = nil
    json_session_data['elements'][1]['startYear'] = nil
    allow(RestClient).to receive(:get).and_return(json_course_data.to_json)
    expect { coursera_course_worker.handle_response_data json_session_data }.to change { Course.count }.by(1)
  end

  it 'sorts a course where all iterations do not have a start date with the id' do
    json_course = json_course_data['elements'][0]
    json_session0 = json_session_data['elements'][0]
    json_session1 = json_session_data['elements'][1]
    json_session0['startDay'] = nil
    json_session0['startMonth'] = nil
    json_session0['startYear'] = nil
    json_session1['startDay'] = nil
    json_session1['startMonth'] = nil
    json_session1['startYear'] = nil
    allow(RestClient).to receive(:get).and_return(json_course_data.to_json)
    expect { coursera_course_worker.handle_response_data json_session_data }.to change { Course.count }.by(2)
    course = Course.find_by(provider_course_id: json_course['id'].to_s + '|' + json_session0['id'].to_s, mooc_provider_id: mooc_provider.id)
    if course.following_iteration_id
      expect(course.id).to be < course.following_iteration_id
    elsif course.previous_iteration_id
      expect(course.id).to be > course.previous_iteration_id
    end
  end
end
