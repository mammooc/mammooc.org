# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MooinCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'mooin') }

  let(:mooin_course_worker) { described_class.new }

  let(:course_data) do
    '{
        "links": {
            "self": "",
            "first": "",
            "last": "",
            "prev": "",
            "next": ""
        },
        "data": [
            {
                "type": "courses",
                "id": "7fb8bf5bcccb7560ab56c02b19d9cb97",
                "attributes": {
                    "name": "Aussprachetraining für arabische Deutschlerner",
                    "url": "https://mooin.oncampus.de/mod/page/view.php?id=1941&lang=de",
                    "abtract": "In diesem sechswöchigen Kurs helfen wir Dir, die deutsche Aussprache zu erlernen. Wir nehmen uns jeden einzelnen Laut der deutschen Sprache vor und vergleichen ihn mit den Lauten, die Du schon aus deiner Sprache kennst. Ist z.B. ein Laut in beiden Sprachen vorhanden, kannst Du sofort mit uns üben. Ist ein Laut neu für Dich, zeigen wir Dir, wie man ihn erlernen und sprechen kann. Das machen wir mit kurzen, ca. zweiminütigen Videos, eines für jeden deutschen Laut. Zusätzlich gibt es Beschreibungen und weiteres Übungsmaterial.",
                    "description": "Was erwartet Dich in diesem Kurs?\r\nDu sprichst (syrisches) Arabisch und willst Deutsch lernen. Dann ist eine der größten Hürden die deutsche Aussprache. Viele Laute der deutschen Sprache kommen im Arabischen nicht vor und bereiten Dir möglicherweise große Probleme. \r\nIn diesem sechswöchigen Kurs helfen wir Dir, die deutsche Aussprache zu erlernen. Wir nehmen uns jeden einzelnen Laut der deutschen Sprache vor und vergleichen ihn mit den Lauten, die Du schon aus deiner Sprache kennst. Ist z.B. ein Laut in beiden Sprachen vorhanden, kannst Du sofort mit uns üben. Ist ein Laut neu für Dich, zeigen wir Dir, wie man ihn erlernen und sprechen kann. Das machen wir mit kurzen, ca. zweiminütigen Videos, eines für jeden deutschen Laut. Zusätzlich gibt es Beschreibungen und weiteres Übungsmaterial. \r\nAm Ende solltest Du jeden Laut und auch schwierige Lautkombinationen des Deutschen mühelos beherrschen. \r\nDer Online-Kurs ist kostenfrei, ganz zwanglos und ohne Prüfung.",
                    "languages": [
                        "de",
                        "ar"
                    ],
                    "workload": 1080,
                    "startDate": "2016-10-15T00:00:00+02:00",
                    "endDate": "2016-11-26T00:00:00+01:00",
                    "doorTime": "2016-08-01T00:00:00+02:00",
                    "image": "http://moodalis.oncampus.de/fhl/images.php?url=moduledescriptions/2f846aceae146509518ce2f6753f28ef/mooinmooc11.jpg",
                    "video": "https://www.youtube.com/watch?v=ZOxOUs2hoBc",
                    "duration": "P6W",
                    "instructors": [
                        {
                            "name": "Prof. Dr. Jürgen Handke"
                        },
                        {
                            "name": "Prof. Dr. Jörn Loviscach"
                        }
                    ],
                    "partnerInstitute": [
                        {
                            "name": "Fachhochschule Lübeck",
                            "url": "https://www.fh-luebeck.de/",
                            "logo": "http://moodalis.oncampus.de/fhl/images.php?url=companies/ace8b2cf201f4fdebd4b0d8175780cf5/logo_fh_luebeck.PNG"
                        },
                        {
                            "name": "Philipps-Universität Marburg",
                            "url": "http://www.uni-marburg.de/",
                            "logo": "http://moodalis.oncampus.de/fhl/images.php?url=companies/713b8c3d69c390a0860ce0b2027e8ea4/uni_mr.jpg"
                        },
                        {
                            "name": "The Virtual Linguistics Campus",
                            "url": "http://linguistics.online.uni-marburg.de/",
                            "logo": "http://moodalis.oncampus.de/fhl/images.php?url=companies/3556b464153dfc2a5af70c2d0c29c462/vlc_logo_full_4c.png"
                        }
                    ],
                    "moocProvider": {
                        "name": "oncampus GmbH",
                        "url": "http://www.oncampus.de/",
                        "logo": "http://moodalis.oncampus.de/fhl/images.php?url=companies/4424c66006ecb1657c1e6d6147f1f0e0/oncampus_logo_neu_2015.png"
                    },
                    "courseCode": "oncampus-MOOC-oin-2016-002518",
                    "licence": "https://creativecommons.org/licenses/by/3.0/de/",
                    "courseMode": "MOOC",
                    "isAccessibleForFree": "false"
                }
            },
            {
                "type": "courses",
                "id": "04c99073eb53d13bab526141ab872f30",
                "attributes": {
                    "name": "Windenergie und Umwelt",
                    "abtract": "Was erwartet dich in diesem Kurs?\r\nDies ist ein Online-Kurs für alle, die Interesse an den Auswirkungen der Windenergietechnik auf Mensch und Umwelt haben und über Maßnahmen zu deren Linderung erfahren möchten. Der Windenergie-und-Umwelt-MOOC dauert acht Wochen und beleuchtet Themen von Ökobilanz über Schallimmission bis hin zu getöteten Vögeln und Fledermäusen. Auf der Plattform mooin gibts dazu gratis Videos, Übungsaufgaben und natürlich viele Möglichkeiten, zusammen zu arbeiten, Hilfe zu erhalten, und Gruppen zur Zusammenarbeit zu finden.",
                    "languages": [
                        "de"
                    ],
                    "startDate": "2016-10-24T00:00:00+02:00",
                    "endDate": "2016-11-28T00:00:00+01:00",
                    "doorTime": "1999-11-30T00:00:00+01:00",
                    "duration": "P8W",
                    "instructors": [
                        {
                            "name": "Prof. Dr. Jörn Loviscach"
                        }
                    ],
                    "moocProvider": {
                        "name": "oncampus GmbH",
                        "url": "http://www.oncampus.de/",
                        "logo": "http://moodalis.oncampus.de/fhl/images.php?url=companies/4424c66006ecb1657c1e6d6147f1f0e0/oncampus_logo_neu_2015.png"
                    },
                    "courseCode": "oncampus-MOOC-oin-2016-002527",
                    "courseMode": "MOOC",
                    "isAccessibleForFree": "true"
                }
            }
        ]
    }'
  end

  let(:json_api_course_data) do
    JSON::Api::Vanilla.parse course_data
  end

  let(:hash_course_data) do
    json_api_course_data.keys.values
  end

  let!(:non_free_track_type) { FactoryGirl.create :mooin_non_free_track_type, type_of_achievement: 'mooin_full_certificate' }
  let!(:free_track_type) { FactoryGirl.create :mooin_free_track_type, type_of_achievement: 'mooin_certificate' }

  it 'delivers MOOCProvider' do
    expect(mooin_course_worker.mooc_provider).to eq mooc_provider
  end

  it 'gets an API response' do
    expect(mooin_course_worker.course_data).not_to be_nil
  end

  it 'loads new courses into database' do
    course_count = Course.count
    mooin_course_worker.handle_response_data hash_course_data
    expect(course_count).to eq Course.count - 2
  end

  it 'loads first course attributes into database' do
    mooin_course_worker.handle_response_data hash_course_data

    json_course = hash_course_data[0]
    course = Course.find_by(provider_course_id: json_course['courseCode'], mooc_provider_id: mooc_provider.id)

    expect(course.name).to eq json_course['name'].strip
    expect(course.provider_course_id).to eq json_course['courseCode']
    expect(course.mooc_provider_id).to eq mooc_provider.id
    expect(course.url).to eq json_course['url']
    expect(course.videoId).to eq json_course['video']
    expect(course.language).to eq json_course['languages'].join(',')
    expect(course.start_date).to eq Time.zone.parse(json_course['startDate'])
    expect(course.end_date).to eq Time.zone.parse(json_course['endDate'])
    expect(course.description).to eq json_course['description']
    expect(course.abstract).to eq json_course['abtract']
    expect(course.workload).to eq json_course['workload'].to_s
    expect(course.provider_given_duration).to eq json_course['duration']
    expect(course.calculated_duration_in_days).to eq ActiveSupport::Duration.parse(json_course['duration']) / 1.day
    expect(course.tracks[0].costs).to be_nil
    expect(course.tracks[0].credit_points).to be_nil
    expect(course.tracks[0].track_type.type_of_achievement).to eq non_free_track_type.type_of_achievement
    expect(course.tracks[0].costs_currency).to be_nil
  end

  it 'loads second course attributes into database' do
    mooin_course_worker.handle_response_data hash_course_data

    json_course = hash_course_data[1]
    course = Course.find_by(provider_course_id: json_course['courseCode'], mooc_provider_id: mooc_provider.id)

    expect(course.name).to eq json_course['name'].strip
    expect(course.provider_course_id).to eq json_course['courseCode']
    expect(course.mooc_provider_id).to eq mooc_provider.id
    expect(course.url).to eq described_class::COURSE_LINK_BODY + json_course['courseCode']
    expect(course.videoId).to be_nil
    expect(course.language).to eq json_course['languages'].join(',')
    expect(course.start_date).to eq Time.zone.parse(json_course['startDate'])
    expect(course.end_date).to eq Time.zone.parse(json_course['endDate'])
    expect(course.description).to be_nil
    expect(course.abstract).to eq json_course['abtract']
    expect(course.workload).to be_nil
    expect(course.provider_given_duration).to eq json_course['duration']
    expect(course.calculated_duration_in_days).to eq 35
    expect(course.tracks[0].costs).to eq 0.0
    expect(course.tracks[0].credit_points).to be_nil
    expect(course.tracks[0].track_type.type_of_achievement).to eq free_track_type.type_of_achievement
    expect(course.tracks[0].costs_currency).to eq "\xe2\x82\xac"
  end

  it 'assigns multiple instructors' do
    mooin_course_worker.handle_response_data hash_course_data
    json_course = hash_course_data[0]
    course = Course.find_by(provider_course_id: json_course['courseCode'], mooc_provider_id: mooc_provider.id)
    expect(course.course_instructors).to eq 'Prof. Dr. Jürgen Handke, Prof. Dr. Jörn Loviscach'
  end

  it 'matches the first organization' do
    mooin_course_worker.handle_response_data hash_course_data
    json_course = hash_course_data[0]
    course = Course.find_by(provider_course_id: json_course['courseCode'], mooc_provider_id: mooc_provider.id)
    expect(course.organisation.name).to eq 'Fachhochschule Lübeck'
    expect(course.organisation.url).to eq 'https://www.fh-luebeck.de/'
  end

  it 'loads courses on perform' do
    expect_any_instance_of(described_class).to receive(:load_courses)
    Sidekiq::Testing.inline!
    described_class.perform_async
  end

  it 'does load courses and handle the response correctly' do
    allow(RestClient).to receive(:get).and_return(course_data)
    expect_any_instance_of(described_class).to receive(:handle_response_data).with(hash_course_data)
    mooin_course_worker.load_courses
  end

  it 'does not duplicate courses' do
    allow(RestClient).to receive(:get).and_return(course_data)
    mooin_course_worker.load_courses
    expect { mooin_course_worker.load_courses }.to change { Course.count }.by(0)
  end

  it 'handles an empty API response' do
    allow(RestClient).to receive(:get).and_return('')
    expect { mooin_course_worker.load_courses }.to change { Course.count }.by(0)
  end

  it 'does not parse an empty string' do
    allow(RestClient).to receive(:get).and_return('')
    expect { mooin_course_worker.course_data }.not_to raise_error
    expect(mooin_course_worker.course_data).to eq []
  end
end
