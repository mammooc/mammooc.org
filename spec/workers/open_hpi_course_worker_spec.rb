require 'rails_helper'

describe OpenHPICourseWorker do

  before(:all) do
    @moocProvider = FactoryGirl.create(:mooc_provider, name: 'openHPI')
  end

  let(:openHPICourseWorker){
    OpenHPICourseWorker.new
  }

  let(:json_course_data) {
    JSON.parse '[{"id":"c1556425-5449-4b05-97b3-42b38a39f6c5","is_enrolled":false,"status":"active","course_code":"pythonjunior2015","categories":[],"language":"de","available_to":"2015-12-07T22:30:00Z","available_from":"2015-11-09T08:00:00Z","name":"Spielend Programmieren lernen 2015!","locked":true,"description":"So einfach war es noch nie die Grundlagen des Programmierens spielerisch zu erlernen. Um am Kurs teilzunehmen, braucht man keine besonderen Vorkenntnisse, nur einen Internetanschluss und einen Rechner. Auf dem Rechner muss keine spezielle Software installiert werden. Notwendig sind nur ein aktueller Browser und eine E-Mail-Adresse, mit der man sich auf openHPI anmelden kann.\r\n\r\nAm Anfang des kostenlosen vierwöchigen Kurses stehen einfache Programmierübungen. Du lernst, eine virtuelle Schildkröte durch deine Programmierung zu steuern. In den darauffolgenden Wochen wirst du mit Schleifen und Funktionen vertraut gemacht, die dir ein grundlegendes Verständnis für die Struktur des Programmierens geben. Bei dem openHPI-Kurs wirst du Lernvideos schauen und im Quiz überprüfen, ob du alles verstanden hast. Direkt im Browser kannst du dann das gelernte Wissen anwenden und drauflos programmieren.\r\n\r\nWenn Du einmal nicht weiter weißt, kannst du im Forum oder den Lerngruppen Unterstützung von anderen Kursteilnehmern finden. Bei erfolgreicher Teilnahme erhältst du nach Kursende ein openHPI-Zeugnis.","lecturer":"Prof. Dr. Martin v. Löwis","visual_url":"https://open.hpi.de/files/fca875a9-d935-4b56-8080-5279b9ef9b54"}]'
  }

  it 'should deliver MOOCProvider' do
    expect(openHPICourseWorker.moocProvider).to eql @moocProvider
  end

  it 'should get an API response' do
    expect(openHPICourseWorker.getCourseData).not_to be_nil
  end

  it 'should load new course into database' do
    courseCount = Course.count
    openHPICourseWorker.handleResponseData json_course_data
    expect(courseCount).to eql Course.count - 1
  end

  it 'should load course attributes into database' do
    openHPICourseWorker.handleResponseData json_course_data

    json_course = json_course_data[0]
    course = Course.find_by(:provider_course_id => json_course['id'], :mooc_provider_id => @moocProvider.id)

    expect(course.name).to eql json_course['name']
    expect(course.provider_course_id).to eql json_course['id']
    expect(course.mooc_provider_id).to eql @moocProvider.id
    expect(course.url).to include json_course['course_code']
    expect(course.language).to eql json_course['language']
    expect(course.imageId).to eql json_course['visual_url']
    expect(course.start_date).to eql Time.parse(json_course['available_from'])
    expect(course.end_date).to eql Time.parse(json_course['available_to'])
    expect(course.description).to eql json_course['description']
    expect(course.course_instructors).to eql [json_course['lecturer']]
    expect(course.open_for_registration).to eql !json_course['locked']
  end
end

