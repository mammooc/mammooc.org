# frozen_string_literal: true
require 'rails_helper'
require 'support/course_worker_spec_helper'

RSpec.describe CourseraCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'coursera') }

  let(:coursera_course_worker) { described_class.new }

  let(:raw_course_data) do
    '{
  "elements": [
    {
      "courseType": "v1.session",
      "partnerLogo": "https://d3njjcbhbojbot.cloudfront.net/api/utilities/v1/imageproxy/https://coursera-university-assets.s3.amazonaws.com/00/947580873611e39c83e7556462158c/UOL-Goldsmiths.png",
      "description": "For anyone who would like to apply their technical skills to creative work ranging from video games to art installations to interactive music, and also for artists who would like to use programming in their artistic practice.",
      "workload": "5-10 hours/week",
      "domainTypes": [
        {
          "domainId": "computer-science",
          "subdomainId": "mobile-and-web-development"
        }
      ],
      "primaryLanguages": [
        "en"
      ],
      "partnerIds": [
        "26"
      ],
      "photoUrl": "https://d3njjcbhbojbot.cloudfront.net/api/utilities/v1/imageproxy/https://d15cw65ipctsrr.cloudfront.net/24/63a093e763b307dc9420e796aeb06a/GoldComputing3.jpg",
      "certificates": [],
      "name": "Creative Programming for Digital Media & Mobile Apps",
      "subtitleLanguages": [
        "en",
        "kk"
      ],
      "id": "v1-228",
      "slug": "digitalmedia",
      "instructorIds": [
        "1620951",
        "1960981",
        "1961937"
      ]
    },
    {
      "courseType": "v2.ondemand",
      "partnerLogo": "",
      "description": "Gamification is the application of game elements and digital game design techniques to non-game problems, such as business and social impact challenges. This course will teach you the mechanisms of gamification, why it has such tremendous potential, and how to use it effectively. For additional information on the concepts described in the course, you can purchase Professor Werbach\'s book For the Win: How Game Thinking Can Revolutionize Your Business in print or ebook format in several languages.",
      "domainTypes": [
        {
          "subdomainId": "design-and-product",
          "domainId": "computer-science"
        },
        {
          "domainId": "business",
          "subdomainId": "marketing"
        }
      ],
      "photoUrl": "https://d3njjcbhbojbot.cloudfront.net/api/utilities/v1/imageproxy/https://coursera.s3.amazonaws.com/topics/gamification/large-icon.png",
      "id": "69Bku0KoEeWZtA4u62x6lQ",
      "slug": "gamification",
      "instructorIds": [
        "226710"
      ],
      "workload": "4-8 hours/week",
      "primaryLanguages": [
        "en"
      ],
      "partnerIds": [
        "6"
      ],
      "certificates": [
        "VerifiedCert"
      ],
      "name": "Gamification",
      "subtitleLanguages": [
        "uk",
        "zh-CN",
        "vi",
        "tr",
        "kk"
      ],
      "startDate": 1447095621493
    }
  ],
  "paging": {
    "next": "2",
    "total": 1925
  },
  "linked": {
    "partners.v1": [
      {
        "name": "University of London",
        "links": {
          "youtube": "user/unioflondon",
          "twitter": "LondonU",
          "website": "http://www.londoninternational.ac.uk/",
          "facebook": "LondonU"
        },
        "id": "26",
        "shortName": "london"
      },
      {
        "name": "University of Pennsylvania",
        "links": {
          "youtube": "/user/PennOpenLearning",
          "website": "http://onlinelearning.upenn.edu/",
          "twitter": "pennonline",
          "facebook": "pennonlinelearning"
        },
        "id": "6",
        "shortName": "penn"
      }
    ],
    "instructors.v1": [
      {
        "lastName": "Gillies",
        "prefixName": "Dr",
        "fullName": "",
        "firstName": "Marco",
        "id": "1620951"
      },
      {
        "lastName": "Yee-King",
        "prefixName": "Dr.",
        "fullName": "Dr Matthew Yee-King",
        "firstName": "Mathew",
        "id": "1960981"
      },
      {
        "lastName": "Dr Mick Grierson",
        "prefixName": "",
        "fullName": "Dr Mick Grierson",
        "firstName": "",
        "id": "1961937"
      },
      {
        "lastName": "Werbach",
        "prefixName": "",
        "fullName": "",
        "firstName": "Kevin",
        "id": "226710"
      }
    ]
  }
}'
  end

  let(:json_course_data) { JSON.parse raw_course_data }
  let(:response_course_data) { [json_course_data] }
  let!(:free_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'nothing' }
  let!(:certificate_course_track_type) { FactoryGirl.create :certificate_course_track_type }

  it 'delivers MOOCProvider' do
    expect(coursera_course_worker.mooc_provider).to eq mooc_provider
  end

  it 'gets an API response' do
    expect(coursera_course_worker.course_data).not_to be_nil
  end

  it 'loads new course into database' do
    allow(RestClient).to receive(:get).and_return(raw_course_data)
    expect { coursera_course_worker.handle_response_data response_course_data }.to change(Course, :count).by(2)
  end

  it 'loads course attributes into database' do
    allow(RestClient).to receive(:get).and_return(raw_course_data)
    coursera_course_worker.handle_response_data response_course_data
    json_course = json_course_data['elements'][1]
    course = Course.find_by(provider_course_id: json_course['id'], mooc_provider_id: mooc_provider.id)

    expect(course.name).to eq json_course['name']
    expect(course.provider_course_id).to eq json_course['id']
    expect(course.mooc_provider_id).to eq mooc_provider.id
    expect(course.url).to include json_course['slug']
    expect(course.language).to eq json_course['primaryLanguages'].join(',')
    expect(course.subtitle_languages).to eq json_course['subtitleLanguages'].join(',')
    expect(course.course_instructors).to eq 'Kevin Werbach'
    expect(course.workload).to eq json_course['workload']
    expect(course.start_date.strftime('%d.%m.%Y')).to eq '09.11.2015'
    expect(course.categories).to match ['computer-science', 'business']
    expect(course.tracks.count).to eq 2
    expect(achievement_type?(course.tracks, :nothing)).to be_truthy
    expect(achievement_type?(course.tracks, :certificate)).to be_truthy
  end

  it 'assigns multiple instructors' do
    allow(RestClient).to receive(:get).and_return(raw_course_data)
    coursera_course_worker.handle_response_data response_course_data
    json_course = json_course_data['elements'][0]
    course = Course.find_by(provider_course_id: json_course['id'], mooc_provider_id: mooc_provider.id)
    expect(course.course_instructors).to eq 'Dr Marco Gillies, Dr. Mathew Yee-King, Dr Mick Grierson'
  end

  it 'matches the correct organization' do
    allow(RestClient).to receive(:get).and_return(raw_course_data)
    coursera_course_worker.handle_response_data response_course_data
    json_course = json_course_data['elements'][0]
    course = Course.find_by(provider_course_id: json_course['id'], mooc_provider_id: mooc_provider.id)
    expect(course.organisation.name).to eq 'University of London'
    expect(course.organisation.url).to eq 'http://www.londoninternational.ac.uk/'
  end

  it 'does not duplicate courses' do
    allow(RestClient).to receive(:get).and_return(raw_course_data)
    coursera_course_worker.handle_response_data response_course_data
    expect { coursera_course_worker.handle_response_data response_course_data }.to change { Course.count }.by(0)
  end
end
