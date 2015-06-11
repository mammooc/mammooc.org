# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe OpenHPICourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI') }

  let(:open_hpi_course_worker) { described_class.new }

  let(:course_data) do
    '[{"id":"c1556425-5449-4b05-97b3-42b38a39f6c5","is_enrolled":false,"status":"active","course_code":"pythonjunior2015","categories":[],"language":"de","available_to":"2015-12-07T22:30:00Z","available_from":"2015-11-09T08:00:00Z","name":"Spielend Programmieren lernen 2015!","locked":true,"description":"So einfach war es noch nie die Grundlagen des Programmierens spielerisch zu erlernen. Um am Kurs teilzunehmen, braucht man keine besonderen Vorkenntnisse, nur einen Internetanschluss und einen Rechner. Auf dem Rechner muss keine spezielle Software installiert werden. Notwendig sind nur ein aktueller Browser und eine E-Mail-Adresse, mit der man sich auf openHPI anmelden kann.\r\n\r\nAm Anfang des kostenlosen vierwöchigen Kurses stehen einfache Programmierübungen. Du lernst, eine virtuelle Schildkröte durch deine Programmierung zu steuern. In den darauffolgenden Wochen wirst du mit Schleifen und Funktionen vertraut gemacht, die dir ein grundlegendes Verständnis für die Struktur des Programmierens geben. Bei dem openHPI-Kurs wirst du Lernvideos schauen und im Quiz überprüfen, ob du alles verstanden hast. Direkt im Browser kannst du dann das gelernte Wissen anwenden und drauflos programmieren.\r\n\r\nWenn Du einmal nicht weiter weißt, kannst du im Forum oder den Lerngruppen Unterstützung von anderen Kursteilnehmern finden. Bei erfolgreicher Teilnahme erhältst du nach Kursende ein openHPI-Zeugnis.","lecturer":"Prof. Dr. Martin v. Löwis","visual_url":"https://open.hpi.de/files/fca875a9-d935-4b56-8080-5279b9ef9b54"}]'
  end

  let(:json_course_data) do
    JSON.parse course_data
  end

  let!(:course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'xikolo_record_of_achievement' }

  it 'delivers MOOCProvider' do
    expect(open_hpi_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'gets an API response' do
    expect(open_hpi_course_worker.course_data).not_to be_nil
  end

  it 'loads new course into database' do
    course_count = Course.count
    open_hpi_course_worker.handle_response_data json_course_data
    expect(course_count).to eql Course.count - 1
  end

  it 'loads course attributes into database' do
    open_hpi_course_worker.handle_response_data json_course_data

    json_course = json_course_data[0]
    course = Course.find_by(provider_course_id: json_course['id'], mooc_provider_id: mooc_provider.id)

    expect(course.name).to eql json_course['name']
    expect(course.provider_course_id).to eql json_course['id']
    expect(course.mooc_provider_id).to eql mooc_provider.id
    expect(course.url).to include json_course['course_code']
    expect(course.language).to eql json_course['language']
    expect(course.imageId).to eql json_course['visual_url']
    expect(course.start_date).to eql Time.zone.parse(json_course['available_from'])
    expect(course.end_date).to eql Time.zone.parse(json_course['available_to'])
    expect(course.description).to eql json_course['description']
    expect(course.course_instructors).to eql json_course['lecturer']
    expect(course.open_for_registration).to eql !json_course['locked']
    expect(course.tracks[0].costs).to eql 0.0
    expect(course.tracks[0].credit_points).to be_nil
    expect(course.tracks[0].track_type.type_of_achievement).to eql course_track_type.type_of_achievement
    expect(course.tracks[0].costs).to eql 0.0
    expect(course.tracks[0].costs_currency).to eql "\xe2\x82\xac"
  end

  it 'loads courses on perform' do
    expect_any_instance_of(described_class).to receive(:load_courses)
    Sidekiq::Testing.inline!
    described_class.perform_async
  end

  it 'does load courses and handle the response correctly' do
    allow(RestClient).to receive(:get).and_return(course_data)
    expect_any_instance_of(described_class).to receive(:handle_response_data).with(json_course_data)
    open_hpi_course_worker.load_courses
  end

  it 'does not duplicate courses' do
    allow(RestClient).to receive(:get).and_return(course_data)
    open_hpi_course_worker.load_courses
    expect { open_hpi_course_worker.load_courses }.to change { Course.count }.by(0)
  end
end
