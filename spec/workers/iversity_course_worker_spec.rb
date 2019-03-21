# frozen_string_literal: true

require 'rails_helper'
require 'support/course_worker_spec_helper'

describe IversityCourseWorker do
  let!(:mooc_provider) { FactoryBot.create(:mooc_provider, name: 'iversity') }

  let(:iversity_course_worker) do
    described_class.new
  end

  let(:courses_response) { '{"courses":[{"id":441,"title":"Algorithmen und Datenstrukturen","discipline":"Computer Science","language":"German","organisations":[{"name":"Universit&auml;t Osnabr&uuml;ck","description":"Die Universit&auml;t Osnabr&uuml;ck ist eine &ouml;ffentlich-rechtliche Hochschule in Niedersachsen mit etwa 12000 Studierenden. Bereits seit 2004 engagieren sich zahlreiche Professoren und Professorinnen im Bereich der neuen Medien und im E-Learning.","image":"https://d1wshrh2fwv7ib.cloudfront.net/organisations/69777780.jpg"}],"instructors":[{"name":"Prof. Dr. Oliver Vornberger","biography":"\u003cp\u003e\u003cem\u003eProfessor f&uuml;r Informatik, Fachbereich Mathemathik/Informatik, Universit&auml;t Osnabr&uuml;ck\u003c/em\u003e\u003c/p\u003e\n\n\u003cp\u003eOliver Vornberger, Jahrgang 1951, leitet die Arbeitsgruppe Medieninformatik an der Universit&auml;t Osnabr&uuml;ck. Zusammen mit Kollegen gr&uuml;ndete er im Jahre 2002 das Zentrum zur Unterst&uuml;tzung der virtuellen Lehre an der Universit&auml;t Osnabr&uuml;ck, genannt virtUOS. Neben seinen Aktivit&auml;ten in Forschung und Lehre engagiert sich Vornberger auch in der Selbstverwaltung: Er leitet als Gesch&auml;ftsf&uuml;hrender Direktor das Institut f&uuml;r Informatik und ist Sprecher des Senats der Universit&auml;t Osnabr&uuml;ck. F&uuml;r sein Engagement in der Lehre erhielt Vornberger im Jahr 2009 auf Vorschlag der Hochschulrektorenkonferenz, finanziert vom Stifterverband f&uuml;r die Deutsche Wissenschaft, den \u0026quot;Ars Legendi Preis f&uuml;r exzellente Hochschullehre\u0026quot;. Im selben Jahr wurde er zusammen mit Karsten Morisse von der Hochschule Osnabr&uuml;ck f&uuml;r seine E-Learning-Aktivit&auml;ten mit dem Wissenschaftspreis des Landes Niedersachsen ausgezeichnet.\u003c/p\u003e\n","image":"https://d1wshrh2fwv7ib.cloudfront.net/users/2624/oliver-vornberger-600-800.jpg"},{"name":"Dr. Nicolas Neubauer","biography":"\u003cp\u003e\u003cem\u003eEhemals Wissenschaftlicher Mitarbeiter, Arbeitsgruppe Medieninformatik, Universit&auml;t Osnabr&uuml;ck\u003c/em\u003e\u003c/p\u003e\n\n\u003cp\u003eNicolas Neubauer studierte Mathematik und Informatik an der Universit&auml;t Osnabr&uuml;ck und schloss sein Studium im November 2010 mit einem Master of Science ab. Im Mai 2014 promovierte er in der Arbeitsgruppe von Prof. Vornberger zum Thema Datenanalyse und Text-Mining und arbeitet aktuell als Consultant bei der codecentric AG in D&uuml;sseldorf.\u003c/p\u003e\n","image":"https://d1wshrh2fwv7ib.cloudfront.net/users/2675/xing.jpeg"},{"name":"Nils Haldenwang","biography":"\u003cp\u003e\u003cem\u003eWissenschaftlicher Mitarbeiter, Arbeitsgruppe Medieninformatik, Universit&auml;t Osnabr&uuml;ck\u003c/em\u003e\u003c/p\u003e\n\n\u003cp\u003eNils Haldenwang studierte Informatik an der Universit&auml;t Osnabr&uuml;ck und erwarb im September 2013 seinen Master of Science. Zu seinen Hauptinteressen geh&ouml;ren die Web-Entwicklung mit Ruby on Rails, Intelligente Informationssysteme und Kombinatorische Optimierung. Am Lehrstuhl von Prof. Vornberger entwickelte er eine zur Zeit bei mehreren Arbeitsgruppen im Einsatz befindliche Web-Applikation zur Verwaltung und Auswertung von Klausuraufgaben in der Hochschullehre. Im Fokus seiner derzeitigen Forschungsbem&uuml;hungen befindet sich die automatisierte Analyse von Textdaten.\u003c/p\u003e\n","image":"https://d1wshrh2fwv7ib.cloudfront.net/users/5712/Avatar.jpg"}],"subtitle":"Das Wort Apps ist in aller Munde. Aber wie funktioniert eine solche Applikation? Und wie kann man Computer-Programme selbst schreiben? Dieser Kurs vermittelt die Grundlage der Informatik und f&uuml;hrt in die Programmiersprache Java ein.","url":"https://iversity.org/en/courses/algorithmen-und-datenstrukturen-april-2015","knowledge_level":"Beginner","image":"https://d1wshrh2fwv7ib.cloudfront.net/courses/dd4d042d-4a8f-4504-bae8-1c79fa093edb/70157969426260.jpg","cover":"https://d1wshrh2fwv7ib.cloudfront.net/courses/dd4d042d-4a8f-4504-bae8-1c79fa093edb/70128154803460.jpg","trailer_video":"https://www.youtube.com/watch?v=Ipzh-cq2KOU","description":"\u003ch4\u003e\u003cstrong\u003eKursbeschreibung\u003c/strong\u003e\u003c/h4\u003e\n\n\u003cp\u003eDer Kurs f&uuml;hrt in das zentrale Gebiet der Informatik ein, auf dem alle anderen Teilgebiete aufbauen: Wie entwickele ich Software? Anhand der Programmiersprache Java werden Algorithmen zum Suchen und Sortieren vorgestellt und die dazu ben&ouml;tigten Datenstrukturen wie Keller, Schlange, Liste, Baum und Graph eingef&uuml;hrt.\u003c/p\u003e\n\n\u003ch4\u003e\u003cstrong\u003eWas lerne ich in diesem Kurs?\u003c/strong\u003e\u003c/h4\u003e\n\n\u003cp\u003eDie Teilnehmer des Kurses werden in die Lage versetzt, eine Problemstellung auf maschinelle L&ouml;sbarkeit hin zu analysieren, daf&uuml;r einen Algorithmus zu entwerfen, die zugeh&ouml;rigen Datenstrukturen zu w&auml;hlen, daraus ein Java-Programm zu entwickeln und dieses zur L&ouml;sung des Problems einzusetzen.\u003c/p\u003e\n\n\u003ch4\u003e\u003cstrong\u003eWelche Vorkenntnisse ben&ouml;tige ich?\u003c/strong\u003e\u003c/h4\u003e\n\n\u003cp\u003eMathematikkenntnisse auf Oberstufenniveau.\u003c/p\u003e\n\n\u003ch4\u003e\u003cstrong\u003eKursplan\u003c/strong\u003e\u003c/h4\u003e\n\n\u003ctable\u003e\u003cthead\u003e\n\u003ctr\u003e\n\u003cth style=\"text-align: left\"\u003e\u003cstrong\u003eKapitel\u003c/strong\u003e\u003c/th\u003e\n\u003cth style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp; \u003cstrong\u003eThema\u003c/strong\u003e\u003c/th\u003e\n\u003c/tr\u003e\n\u003c/thead\u003e\u003ctbody\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 1\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;       Einf&uuml;hrung\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 2\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;       Systemumgebung\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 3\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;       Java\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 4\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;       Datentypen\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 5\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;       Felder\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 6\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;      Methoden\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 7\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;       Rekursion\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 8\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;       Komplexit&auml;t\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 9\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;       Sortieren\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 10\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;      Objektorientierung\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 11\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;      Abstrakte Datentypen\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 12\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;      Suchb&auml;ume\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 13\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;      Hashing\u003c/td\u003e\n\u003c/tr\u003e\n\u003ctr\u003e\n\u003ctd style=\"text-align: left\"\u003eKapitel 14\u003c/td\u003e\n\u003ctd style=\"text-align: left\"\u003e\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;\u0026nbsp;      Graphen\u003c/td\u003e\n\u003c/tr\u003e\n\u003c/tbody\u003e\u003c/table\u003e\n","start_date":"2015-04-14T13:00:00.000+02:00","end_date":"2015-07-14T11:38:00.000+02:00","duration":"14","ects_available":"true","verifications":[{"title":"Audit Track","description":"\u003cul class=\'list-none\'\u003e\n\u003cli\u003eAll Course Material\u003c/li\u003e\n\u003cli\u003eCourse Community\u003c/li\u003e\n\u003cli\u003eStatement of Participation\u003c/li\u003e\n\u003cli\u003eFlexible Upgrade\u003c/li\u003e\n\u003c/ul\u003e","price":null,"credits":null},{"title":"ECTS-Track","description":"\u003cul class=\"list-none\"\u003e\r\n\u003cli\u003eBenotete Pr&auml;senzpr&uuml;fung\u003c/li\u003e\r\n\u003cli\u003eLeistungsnachweis\u003c/li\u003e\r\n\u003cli\u003eZertifikatszusatz\u003c/li\u003e\r\n\u003cli\u003e6 ECTS-Punkte\u003c/li\u003e\r\n\u003c/ul\u003e\r\n","price":"149 \u20AC","credits":null},{"title":"Certificate Track","description":"\u003cul class=\'list-none\'\u003e\n\u003cli\u003eCourse Community\u003c/li\u003e\n\u003cli\u003eGraded Online Exam\u003c/li\u003e\n\u003cli\u003eCertificate of Accomplishment\u003c/li\u003e\n\u003cli\u003eCertificate Supplement\u003c/li\u003e\n\u003c/ul\u003e","price":"49 \u20AC","credits":null},{"title":"Schüler-Track","description":"\u003cul class=\"list-none\"\u003e\r\n\u003cli\u003eBenotete Pr&auml;senzpr&uuml;fung\u003c/li\u003e\r\n\u003cli\u003eLeistungsnachweis\u003c/li\u003e\r\n\u003cli\u003eZertifikatszusatz\u003c/li\u003e\r\n\u003cli\u003e5 ECTS-Punkte\u003c/li\u003e\r\n\u003c/ul\u003e\r\n","price":"49 \u20AC","credits":null},{"id":1743,"title":"Statement of Participation","description":"\u003cul class=\'list-none\'\u003e\n\u003cli\u003e\u003c/li\u003e\n\u003cli\u003e\u003c/li\u003e\n\u003cli class=\"faded\"\u003e\u003c/li\u003e\n\u003cli class=\"faded\"\u003e\u003c/li\u003e\n\u003c/ul\u003e","price":null,"credits":null}]}]}' }
  let(:courses_json) { JSON.parse courses_response }
  let!(:free_course_track_type) { FactoryBot.create :course_track_type, type_of_achievement: 'iversity_record_of_achievement' }
  let!(:certificate_course_track_type) { FactoryBot.create :certificate_course_track_type, type_of_achievement: 'iversity_certificate' }
  let!(:ects_course_track_type) { FactoryBot.create :ects_course_track_type, type_of_achievement: 'iversity_ects' }
  let!(:ects_pupils_track_type) { FactoryBot.create :ects_pupils_track_type, type_of_achievement: 'iversity_ects_pupils' }
  let!(:iversity_statement_track_type) { FactoryBot.create :iversity_statement_track_type, type_of_achievement: 'iversity_statement_of_participation' }

  it 'delivers MOOCProvider' do
    expect(iversity_course_worker.mooc_provider).to eq mooc_provider
  end

  it 'gets an API response' do
    skip 'The API might have changed.'
    expect(iversity_course_worker.course_data).not_to be_nil
  end

  it 'loads new course into database' do
    expect { iversity_course_worker.handle_response_data courses_json }.to change(Course, :count).by(1)
  end

  it 'loads course attributes into database' do
    allow(RestClient).to receive(:get).and_return(courses_response)
    iversity_course_worker.handle_response_data courses_json
    course = Course.find_by(provider_course_id: courses_json['courses'][0]['id'], mooc_provider_id: mooc_provider.id)

    expect(course.name).to eq courses_json['courses'][0]['title']
    expect(course.url).to include courses_json['courses'][0]['url']
    expect(course.abstract).to eq courses_json['courses'][0]['subtitle']
    expect(course.language).to eq 'de'
    expect(course.videoId).to eq courses_json['courses'][0]['trailer_video']
    expect(course.start_date.to_datetime).to eq courses_json['courses'][0]['start_date'].to_datetime
    expect(course.end_date.to_datetime).to eq courses_json['courses'][0]['end_date'].to_datetime
    expect(course.difficulty).to eq courses_json['courses'][0]['knowledge_level ']

    expect(course.tracks.count).to eq 5
    expect(achievement_type?(course.tracks, :iversity_record_of_achievement)).to be_truthy
    expect(achievement_type?(course.tracks, :iversity_certificate)).to be_truthy
    expect(achievement_type?(course.tracks, :iversity_ects)).to be_truthy
    expect(achievement_type?(course.tracks, :iversity_ects_pupils)).to be_truthy
    expect(achievement_type?(course.tracks, :iversity_statement_of_participation)).to be_truthy

    expect(course.provider_course_id).to eq courses_json['courses'][0]['id'].to_s
    expect(course.mooc_provider_id).to eq mooc_provider.id
    expect(course.categories).to match_array [courses_json['courses'][0]['discipline']]
    expect(course.course_instructors).to eq 'Prof. Dr. Oliver Vornberger, Dr. Nicolas Neubauer, Nils Haldenwang'
    expect(course.description).to eq courses_json['courses'][0]['description']
    expect(course.calculated_duration_in_days).to eq 91
    expect(course.provider_given_duration).to eq courses_json['courses'][0]['duration']
  end

  it 'parses another language as well' do
    courses_json['courses'][0]['language'] = 'English'
    iversity_course_worker.handle_response_data courses_json
    course = Course.find_by(provider_course_id: courses_json['courses'][0]['id'], mooc_provider_id: mooc_provider.id)
    expect(course.language).to eq 'en'
  end

  it 'parses more then one language' do
    courses_json['courses'][0]['language'] = %w[en es]
    iversity_course_worker.handle_response_data courses_json
    course = Course.find_by(provider_course_id: courses_json['courses'][0]['id'], mooc_provider_id: mooc_provider.id)
    expect(course.language).to eq 'en,es'
  end

  it 'parses if only one plan is offered' do
    courses_json['courses'][0]['verifications'] = JSON.parse '{"title":"Audit Track","description":"\u003cul class=\'list-none\'\u003e\n\u003cli\u003eAll Course Material\u003c/li\u003e\n\u003cli\u003eCourse Community\u003c/li\u003e\n\u003cli\u003eStatement of Participation\u003c/li\u003e\n\u003cli\u003eFlexible Upgrade\u003c/li\u003e\n\u003c/ul\u003e","price":null,"credits":null}'
    iversity_course_worker.handle_response_data courses_json
    course = Course.find_by(provider_course_id: courses_json['courses'][0]['id'], mooc_provider_id: mooc_provider.id)
    expect(course.tracks.count).to eq 1
    expect(achievement_type?(course.tracks, :iversity_record_of_achievement)).to be_truthy
  end

  it 'parses if only one instructor is responsible for this course' do
    courses_json['courses'][0]['instructors'] = JSON.parse '{"name":"Prof. Dr. Oliver Vornberger","biography":"\u003cp\u003e\u003cem\u003eProfessor f&uuml;r Informatik, Fachbereich Mathemathik/Informatik, Universit&auml;t Osnabr&uuml;ck\u003c/em\u003e\u003c/p\u003e\n\n\u003cp\u003eOliver Vornberger, Jahrgang 1951, leitet die Arbeitsgruppe Medieninformatik an der Universit&auml;t Osnabr&uuml;ck. Zusammen mit Kollegen gr&uuml;ndete er im Jahre 2002 das Zentrum zur Unterst&uuml;tzung der virtuellen Lehre an der Universit&auml;t Osnabr&uuml;ck, genannt virtUOS. Neben seinen Aktivit&auml;ten in Forschung und Lehre engagiert sich Vornberger auch in der Selbstverwaltung: Er leitet als Gesch&auml;ftsf&uuml;hrender Direktor das Institut f&uuml;r Informatik und ist Sprecher des Senats der Universit&auml;t Osnabr&uuml;ck. F&uuml;r sein Engagement in der Lehre erhielt Vornberger im Jahr 2009 auf Vorschlag der Hochschulrektorenkonferenz, finanziert vom Stifterverband f&uuml;r die Deutsche Wissenschaft, den \u0026quot;Ars Legendi Preis f&uuml;r exzellente Hochschullehre\u0026quot;. Im selben Jahr wurde er zusammen mit Karsten Morisse von der Hochschule Osnabr&uuml;ck f&uuml;r seine E-Learning-Aktivit&auml;ten mit dem Wissenschaftspreis des Landes Niedersachsen ausgezeichnet.\u003c/p\u003e\n","image":"https://d1wshrh2fwv7ib.cloudfront.net/users/2624/oliver-vornberger-600-800.jpg"}'
    iversity_course_worker.handle_response_data courses_json
    course = Course.find_by(provider_course_id: courses_json['courses'][0]['id'], mooc_provider_id: mooc_provider.id)
    expect(course.course_instructors).to eq 'Prof. Dr. Oliver Vornberger'
  end
end
