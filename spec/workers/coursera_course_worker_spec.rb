require 'rails_helper'

describe CourseraCourseWorker do

  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'coursera') }

  let(:coursera_course_worker){
    CourseraCourseWorker.new
  }

  let(:json_session_data) {
    JSON.parse '{"elements":[{"id":90,"signatureTrackPrice":50.5,"courseId":9,"homeLink":"https://class.coursera.org/crypto-2012-002/","active":true,"durationString":"6 weeks","startDay":11,"startMonth":6,"startYear":2012,"eligibleForCertificates":true,"eligibleForSignatureTrack":false,"links":{}},{"id":91,"courseId":9,"homeLink":"https://class.coursera.org/crypto-2012-002/","active":true,"durationString":"6 weeks","startDay":13,"startMonth":6,"startYear":2012,"eligibleForCertificates":true,"eligibleForSignatureTrack":false,"links":{}}],"linked":{}}'
  }
  let(:json_course_data) {
    JSON.parse '{"elements":[{"id":9,"shortName":"crypto","name":"Cryptography I","language":"en","photo":"https://s3.amazonaws.com/coursera/topics/crypto/large-icon.png","shortDescription":"Learn about the inner workings of cryptographic primitives and how to apply this knowledge in real-world applications!","subtitleLanguagesCsv":"","video":"0t1oCt88XJk","aboutTheCourse":"<p>Cryptography is an indispensable tool for protecting information in computer systems. This course explains the inner workings of cryptographic primitives and how to correctly use them. Students will learn how to reason about the security of cryptographic constructions and how to apply this knowledge to real-world applications. The course begins with a detailed discussion of how two parties who have a shared secret key can communicate securely when a powerful adversary eavesdrops and tampers with traffic. We will examine many deployed protocols and analyze mistakes in existing systems. The second half of the course discusses public-key techniques that let two or more parties generate a shared secret key. We will cover the relevant number theory and discuss public-key encryption and basic key-exchange.&nbsp;Throughout the course students will be exposed to many exciting open problems in the field.</p>\n<p>The course will include written homeworks and programming labs. The course is self-contained, however it will be helpful to have a basic understanding of discrete probability theory.</p><p>A preview of the course, including lectures and homework assignments, is available at this <a href=\"https://class.coursera.org/crypto-preview\" target=\"_blank\">preview site</a>.</p>","targetAudience":1,"instructor":"Dan Boneh, Professor","estimatedClassWorkload":"5-7 hours/week","recommendedBackground":"","links":{}}],"linked":{}}'
  }
  it 'should deliver MOOCProvider' do
    expect(coursera_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'should get an API response' do
    expect(coursera_course_worker.get_course_data).not_to be_nil
  end

  it 'should load new course into database' do
    expect{coursera_course_worker.handle_response_data json_session_data}.to change(Course, :count).by(2)
  end

  it 'should load course attributes into database' do
    coursera_course_worker.handle_response_data json_session_data
    json_session = json_session_data['elements'][0]
    json_course = json_course_data['elements'][0]
    course = Course.find_by(:provider_course_id => json_course['id'].to_s + '|' + json_session['id'].to_s, :mooc_provider_id => mooc_provider.id)

    expect(course.name).to eql json_course['name']
    expect(course.provider_course_id).to eql json_course['id'].to_s + '|' + json_session['id'].to_s
    expect(course.mooc_provider_id).to eql mooc_provider.id
    expect(course.url).to include json_course['shortName']
    expect(course.language).to eql json_course['language']
    expect(course.imageId).to eql json_course['photo']
    expect(course.start_date).to eql Time.parse DateTime.new(json_session['startYear'],json_session['startMonth'],json_session['startDay']).to_s
    expect(course.abstract).to eql json_course['shortDescription']
    expect(course.course_instructors).to eql json_course['instructor']
    expect(course.provider_given_duration).to eql json_session['durationString']
    expect(course.subtitle_languages).to eql json_course['subtitleLanguagesCsv']
    expect(course.videoId).to eql json_course['video']
    expect(course.description).to eql json_course['aboutTheCourse']
    expect(course.workload).to eql json_course['estimatedClassWorkload']
    expect(course.difficulty).to eql 'Advanced undergraduates or beginning graduates'
    expect(course.requirements).to eql nil
    expect(course.type_of_achievement).to eql 'Certificate'
    expect(course.costs).to eql 50.5
    expect(course.price_currency).to eql '$'
    expect(course.has_free_version).to be true
    expect(course.has_paid_version).to be_falsey


  end

  it 'should link iterations in correct order' do
    coursera_course_worker.handle_response_data json_session_data
    json_course = json_course_data['elements'][0]
    json_session1 = json_session_data['elements'][0]
    json_session2 = json_session_data['elements'][1]
    course1 = Course.find_by(:provider_course_id => json_course['id'].to_s + '|' + json_session1['id'].to_s, :mooc_provider_id => mooc_provider.id)
    course2 = Course.find_by(:provider_course_id => json_course['id'].to_s + '|' + json_session2['id'].to_s, :mooc_provider_id => mooc_provider.id)
    expect(course1.following_iteration_id).to eql course2.id
    expect(course2.previous_iteration_id).to eql course1.id
  end

end

