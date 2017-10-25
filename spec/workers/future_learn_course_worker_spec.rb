# frozen_string_literal: true

require 'rails_helper'
require 'support/course_worker_spec_helper'

describe FutureLearnCourseWorker do
  let!(:mooc_provider) { FactoryBot.create(:mooc_provider, name: 'FutureLearn') }

  let(:future_learn_course_worker) do
    described_class.new
  end

  let(:courses_response) do
    '[
  {
    "uuid": "d3995b4d-3aa4-469b-abe8-3de3bfa43657",
    "url": "http://www.futurelearn.com/courses/begin-programming?utm_campaign=Courses+feed&utm_medium=courses-feed&utm_source=courses-feed",
    "image_url": "https://ugc.futurelearn.com/uploads/images/c9/9c/regular_c99cbca8-6bf5-44f2-9bb9-17c21efc8e72.jpg",
    "name": "Begin Programming: Build Your First Mobile Game",
    "introduction": "Learn basic Java programming by developing a simple mobile game that you can run on your computer, Android phone, or tablet. ",
    "description": "<p>Programming is everywhere: in dishwashers, cars and even space shuttles. This course will help you to understand how programs work and guide you through creating your own computer program – a mobile game.</p>\n\n<p>Whether you’re a complete newcomer to programming, or have some basic skills, this course provides a challenging but fun way to start programming in Java. Over seven weeks we will introduce the basic constructs that are used in many programming languages and help you to put this knowledge into practice by changing the game code we have provided. You’ll have the freedom to create a game that’s unique to you, with support from the community and educators if you get stuck. You’ll learn how to create algorithms to solve problems and translate these into code, using the same tools as industry professionals worldwide. We will be using Google’s Android Studio as the platform for programming.</p>\n\n<p>The course will combine video introductions, on-screen examples, downloadable guides, articles and discussions to help you understand the principles behind computer programs and the building blocks that are used to create them. Multiple choice quizzes will help you to check your understanding, while exercises each week will show you how to use your new skills to improve your game. Expert guidance from staff at the <a href=\"http://www.reading.ac.uk/sse/\" title=\"School of Systems Engineering, University of Reading\">School of Systems Engineering</a> at the University of Reading, UK, will help to you to get hands-on experience of programming.</p>\n\n<p>At the end of the course you’ll have a complete game that can be played on an Android phone or tablet, or even your computer. You can share it with your friends and family, use your new knowledge to improve the game further, or even create new games of your own!</p>\n\n<p>You can find out more about this course in Professor Shirley Williams’s blog post on the <a href=\"https://about.futurelearn.com/blog/shortage-of-programmers/\">shortage of programmers</a>.</p>\n",
    "language": "en",
    "hours_per_week": 4,
    "has_certificates": true,
    "categories": [
      "Online & Digital"
    ],
    "educator": "Karsten Øster Lundqvist (Lead Educator)",
    "organisation": {
      "url": "http://www.reading.ac.uk",
      "name": "University of Reading"
    },
    "trailer": "//view.vzaar.com/4251365/video",
    "runs": [
      {
        "uuid": "6f24cc01-d18f-42f8-b679-ed0830db5d32",
        "start_date": "2013-10-28",
        "duration_in_weeks": 7
      },
      {
        "uuid": "2b3b6da3-6da7-4ae2-84fe-9ddf08f91327",
        "start_date": "2014-02-24",
        "duration_in_weeks": 7
      },
      {
        "uuid": "ed6a9426-6518-453f-9a13-6e6b1b8779ca",
        "start_date": "2014-10-20",
        "duration_in_weeks": 7}]
  }]'
  end

  let(:courses_json) { JSON.parse courses_response }
  let!(:free_course_track_type) { FactoryBot.create :course_track_type, type_of_achievement: 'nothing' }
  let!(:certificate_course_track_type) { FactoryBot.create :certificate_course_track_type, type_of_achievement: 'certificate' }

  it 'delivers MOOCProvider' do
    expect(future_learn_course_worker.mooc_provider).to eq mooc_provider
  end

  it 'gets an API response' do
    expect(future_learn_course_worker.course_data).not_to be_nil
  end

  it 'loads new course into database' do
    expect { future_learn_course_worker.handle_response_data courses_json }.to change(Course, :count).by(3)
  end

  it 'loads course attributes into database' do
    allow(RestClient).to receive(:get).and_return(courses_response)
    future_learn_course_worker.handle_response_data courses_json

    course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, courses_json[0]['runs'].first['uuid'])

    expect(course.name).to eq courses_json[0]['name']
    expect(course.url).to eq courses_json[0]['url']
    expect(course.abstract).to eq courses_json[0]['introduction']
    expect(course.language).to eq courses_json[0]['language']
    expect(course.videoId).to eq courses_json[0]['trailer']
    expect(course.start_date.to_datetime).to eq courses_json[0]['runs'].first['start_date'].to_datetime
    expect(course.workload).to eq "#{courses_json[0]['hours_per_week']} hours per week"

    expect(course.tracks.count).to eq 1
    expect(achievement_type?(course.tracks, :certificate)).to be_truthy

    expect(course.provider_course_id).to eq courses_json[0]['runs'].first['uuid'].to_s
    expect(course.mooc_provider_id).to eq mooc_provider.id
    expect(course.categories).to match_array courses_json[0]['categories']
    expect(course.course_instructors).to eq courses_json[0]['educator']
    expect(course.description).to eq courses_json[0]['description']
    expect(course.calculated_duration_in_days).to eq 49
    expect(course.provider_given_duration).to eq "#{courses_json[0]['runs'].first['duration_in_weeks']} weeks"
  end

  it 'links iterations in correct order' do
    allow(RestClient).to receive(:get).and_return(courses_response)
    future_learn_course_worker.handle_response_data courses_json

    course1 = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, courses_json[0]['runs'].first['uuid'])
    course2 = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, courses_json[0]['runs'].second['uuid'])
    course3 = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, courses_json[0]['runs'].third['uuid'])

    expect(course1.previous_iteration).to be_nil
    expect(course1.following_iteration).to eq course2
    expect(course2.previous_iteration).to eq course1
    expect(course2.following_iteration).to eq course3
    expect(course3.previous_iteration).to eq course2
    expect(course3.following_iteration).to be_nil
  end

  it 'does not link iterations without start_date' do
    courses_json[0]['runs'].first['start_date'] = nil
    allow(RestClient).to receive(:get).and_return(courses_json)
    future_learn_course_worker.handle_response_data courses_json

    course1 = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, courses_json[0]['runs'].first['uuid'])
    course2 = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, courses_json[0]['runs'].second['uuid'])
    course3 = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, courses_json[0]['runs'].third['uuid'])

    expect(course1.following_iteration).to be_nil
    expect(course2.previous_iteration).to be_nil
    expect(course2.following_iteration).to eq course3
    expect(course3.previous_iteration).to eq course2
    expect(course3.following_iteration).to be_nil
  end

  it 'does not duplicate courses' do
    allow(RestClient).to receive(:get).and_return(courses_json)
    future_learn_course_worker.handle_response_data courses_json
    expect { future_learn_course_worker.handle_response_data courses_json }.to change { Course.count }.by(0)
  end
end
